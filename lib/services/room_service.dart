import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/board_size.dart';
import '../models/player_profile.dart';
import '../models/room_data.dart';
import '../models/room_move.dart';
import 'room_code.dart';

class RoomNotFoundException implements Exception {}

class RoomFullException implements Exception {}

/// Talks to the `rooms` Firestore collection: creating/joining rooms,
/// streaming live room state, and appending moves. Two players share a
/// room document; each claimed edge is appended to its `moves` array and
/// replayed locally by both clients through [GameEngine.claimEdge], so
/// the document itself never stores derived board state.
class RoomService {
  RoomService({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  // Resolved lazily (not in the constructor) so simply constructing a
  // RoomService — e.g. as an app-wide Provider — doesn't require Firebase
  // to already be initialized; only actually talking to Firestore does.
  FirebaseFirestore get _db => _firestoreOverride ?? FirebaseFirestore.instance;

  /// Written to every room as `expireAt`. Used to recognise "our" room
  /// during stale-room cleanup, and ready for a Firestore TTL policy on
  /// `rooms.expireAt` if the project ever moves to the Blaze plan.
  static const roomTtl = Duration(hours: 2);

  // The room this device last created or joined, persisted so that a
  // room left behind by a crash / force-quit / lost connection can be
  // deleted on the next app launch (see [cleanUpStaleRoom]).
  static const _pendingCodeKey = 'pendingRoomCode';
  static const _pendingExpireKey = 'pendingRoomExpireAtMs';

  Future<void> _rememberRoom(String code, Object? expireAt) async {
    if (expireAt is! Timestamp) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingCodeKey, code);
      await prefs.setInt(_pendingExpireKey, expireAt.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('RoomService: could not remember room: $e');
    }
  }

  Future<void> _forgetRoom(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_pendingCodeKey) != code) return;
      await prefs.remove(_pendingCodeKey);
      await prefs.remove(_pendingExpireKey);
    } catch (e) {
      debugPrint('RoomService: could not forget room: $e');
    }
  }

  /// Call once on app start. If the previous session left a room behind
  /// (the app was killed before [deleteRoom] ran), delete it now. The
  /// stored `expireAt` must match the live document, so a room that was
  /// already deleted and whose code has since been reused by someone
  /// else is never touched.
  Future<void> cleanUpStaleRoom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_pendingCodeKey);
      final expireMs = prefs.getInt(_pendingExpireKey);
      if (code == null) return;
      final snap = await _rooms.doc(code).get();
      final live = snap.data()?['expireAt'];
      if (snap.exists &&
          live is Timestamp &&
          live.millisecondsSinceEpoch == expireMs) {
        await _rooms.doc(code).delete();
      }
      await prefs.remove(_pendingCodeKey);
      await prefs.remove(_pendingExpireKey);
    } catch (e) {
      // Offline or Firestore unavailable — keep the record and retry on
      // the next launch.
      debugPrint('RoomService: stale room cleanup failed: $e');
    }
  }

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('rooms');

  // A base64 string this long decodes to ~256KB, comfortably inside
  // Firestore's 1MiB document limit even with both avatars and a full
  // moves array present. Avatars are already resized to 800px/quality 85
  // before picking, so a legitimate photo never gets close to this.
  static const _maxAvatarB64Length = 350000;

  // Player avatars are picked from the device's own gallery, so a raw
  // avatarPath (a local file path, or a blob: URL on web) only ever
  // resolves on the device that picked it. Embedding the picked bytes as
  // base64 directly in the room document is what lets the *other*
  // player's device actually load the photo, with no separate storage
  // service required.
  String? _encodeAvatar(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    final b64 = base64Encode(bytes);
    // Avatar sync is a nice-to-have, not required to play — an
    // unexpectedly large photo is dropped instead of blocking the room.
    if (b64.length > _maxAvatarB64Length) {
      debugPrint(
        '_encodeAvatar: dropped avatar, b64 length ${b64.length} > '
        '$_maxAvatarB64Length',
      );
      return null;
    }
    return b64;
  }

  Future<String> createRoom({
    required PlayerProfile host,
    required BoardSize boardSize,
  }) async {
    final hostAvatarB64 = _encodeAvatar(host.avatarBytes);
    final expireAt = Timestamp.fromDate(DateTime.now().add(roomTtl));
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = generateRoomCode();
      final ref = _rooms.doc(code);
      final created = await _db.runTransaction<bool>((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) return false;
        tx.set(ref, {
          'dotsWide': boardSize.dotsWide,
          'dotsHigh': boardSize.dotsHigh,
          'hostName': host.name,
          'hostColor': host.color.toARGB32(),
          'hostAvatarB64': hostAvatarB64,
          'guestName': null,
          'guestColor': null,
          'guestAvatarB64': null,
          'status': RoomStatus.waiting.name,
          'moves': <Map<String, dynamic>>[],
          'createdAt': FieldValue.serverTimestamp(),
          'expireAt': expireAt,
        });
        return true;
      });
      if (created) {
        await _rememberRoom(code, expireAt);
        return code;
      }
    }
    throw StateError('Could not allocate a unique room code.');
  }

  Future<RoomData> joinRoom({
    required String code,
    required PlayerProfile guest,
  }) async {
    final guestAvatarB64 = _encodeAvatar(guest.avatarBytes);
    final ref = _rooms.doc(code);
    Object? expireAt;
    final room = await _db.runTransaction<RoomData>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw RoomNotFoundException();
      final data = snap.data()!;
      expireAt = data['expireAt'];
      if (data['status'] != RoomStatus.waiting.name) {
        throw RoomFullException();
      }
      tx.update(ref, {
        'guestName': guest.name,
        'guestColor': guest.color.toARGB32(),
        'guestAvatarB64': guestAvatarB64,
        'status': RoomStatus.active.name,
      });
      return RoomData.fromMap(code, {
        ...data,
        'guestName': guest.name,
        'guestColor': guest.color.toARGB32(),
        'guestAvatarB64': guestAvatarB64,
        'status': RoomStatus.active.name,
      });
    });
    await _rememberRoom(code, expireAt);
    return room;
  }

  Stream<RoomData?> watchRoom(String code) {
    return _rooms.doc(code).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return RoomData.fromMap(code, data);
    });
  }

  Future<void> submitMove(String code, RoomMove move) {
    return _rooms.doc(code).update({
      'moves': FieldValue.arrayUnion([move.toMap()]),
    });
  }

  Future<void> deleteRoom(String code) async {
    await _rooms.doc(code).delete();
    await _forgetRoom(code);
  }
}
