import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';

/// A player taking part in a match: a display name, their claimed line
/// color, and an optional gallery photo used as their avatar. When no
/// photo is picked, [color] alone is used to fill their captured boxes.
class PlayerProfile {
  PlayerProfile({
    required this.name,
    required this.color,
    this.avatarPath,
    this.avatarBytes,
  });

  String name;
  Color color;

  /// Local-only preview path of a freshly picked photo (a filesystem path
  /// on native, a `blob:` URL on web) — never valid on another device, so
  /// it's only a fallback for when [avatarBytes] isn't available yet.
  String? avatarPath;

  /// Raw bytes of the picked photo. This is what gets rendered directly
  /// (via `Image.memory`) and, base64-encoded, synced through Firestore —
  /// it's the only avatar source that resolves on the *other* player's
  /// device too.
  Uint8List? avatarBytes;

  bool get hasAvatar =>
      (avatarBytes != null && avatarBytes!.isNotEmpty) ||
      (avatarPath != null && avatarPath!.isNotEmpty);

  PlayerProfile copyWith({
    String? name,
    Color? color,
    String? avatarPath,
    Uint8List? avatarBytes,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      color: color ?? this.color,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarBytes: avatarBytes ?? this.avatarBytes,
    );
  }
}
