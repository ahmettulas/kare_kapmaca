import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show Uint8List, debugPrint;

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
        });
        return true;
      });
      if (created) return code;
    }
    throw StateError('Could not allocate a unique room code.');
  }

  Future<RoomData> joinRoom({
    required String code,
    required PlayerProfile guest,
  }) async {
    final guestAvatarB64 = _encodeAvatar(guest.avatarBytes);
    final ref = _rooms.doc(code);
    return _db.runTransaction<RoomData>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw RoomNotFoundException();
      final data = snap.data()!;
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

  Future<void> deleteRoom(String code) {
    return _rooms.doc(code).delete();
  }
}
