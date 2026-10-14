import 'dart:convert';

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';

import 'board_size.dart';
import 'player_profile.dart';
import 'room_move.dart';

enum RoomStatus { waiting, active, finished }

/// A parsed snapshot of a `rooms/{code}` Firestore document.
class RoomData {
  const RoomData({
    required this.code,
    required this.boardSize,
    required this.host,
    required this.guest,
    required this.status,
    required this.moves,
  });

  final String code;
  final BoardSize boardSize;
  final PlayerProfile host;
  final PlayerProfile? guest;
  final RoomStatus status;
  final List<RoomMove> moves;

  static Uint8List? _decodeAvatar(dynamic b64) {
    if (b64 is! String || b64.isEmpty) return null;
    return base64Decode(b64);
  }

  factory RoomData.fromMap(String code, Map<String, dynamic> map) {
    final guestName = map['guestName'] as String?;
    return RoomData(
      code: code,
      boardSize: BoardSize(map['dotsWide'] as int, map['dotsHigh'] as int),
      host: PlayerProfile(
        name: map['hostName'] as String,
        color: Color(map['hostColor'] as int),
        avatarBytes: _decodeAvatar(map['hostAvatarB64']),
      ),
      guest: guestName == null
          ? null
          : PlayerProfile(
              name: guestName,
              color: Color(map['guestColor'] as int),
              avatarBytes: _decodeAvatar(map['guestAvatarB64']),
            ),
      status: RoomStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoomStatus.waiting,
      ),
      moves: (map['moves'] as List<dynamic>? ?? const [])
          .map((m) => RoomMove.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }
}
