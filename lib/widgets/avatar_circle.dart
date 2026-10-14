import 'dart:io';

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Builds the avatar image for a player, or `null` if they have none.
///
/// [avatarBytes] (the raw photo bytes, base64-synced through Firestore) is
/// preferred because it's the only source that resolves on the *other*
/// player's device, and it renders the same way (`Image.memory`) on every
/// platform. [avatarPath] (a local filesystem path, or a `blob:` URL on
/// web) is a fallback for when bytes aren't available.
Widget? buildAvatarImage({
  required Uint8List? avatarBytes,
  required String? avatarPath,
  required BoxFit fit,
  required Widget Function() errorBuilder,
}) {
  if (avatarBytes != null && avatarBytes.isNotEmpty) {
    return Image.memory(
      avatarBytes,
      fit: fit,
      errorBuilder: (_, error, _) {
        debugPrint('buildAvatarImage: Image.memory decode failed: $error');
        return errorBuilder();
      },
    );
  }
  if (avatarPath != null && avatarPath.isNotEmpty) {
    // image_picker returns a blob: URL on web, not a real filesystem
    // path — Image.file needs dart:io and isn't supported there at all.
    return kIsWeb
        ? Image.network(
            avatarPath,
            fit: fit,
            errorBuilder: (_, _, _) => errorBuilder(),
          )
        : Image.file(
            File(avatarPath),
            fit: fit,
            errorBuilder: (_, _, _) => errorBuilder(),
          );
  }
  return null;
}

/// Circular player avatar. Shows the picked gallery photo when present,
/// otherwise falls back to the player's color with their initial.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.name,
    required this.color,
    this.avatarPath,
    this.avatarBytes,
    this.size = 44,
    this.editable = false,
    this.borderColor,
  });

  final String name;
  final Color color;
  final String? avatarPath;
  final Uint8List? avatarBytes;
  final double size;
  final bool editable;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final image = buildAvatarImage(
      avatarBytes: avatarBytes,
      avatarPath: avatarPath,
      fit: BoxFit.cover,
      errorBuilder: () => _InitialLabel(initial: initial, size: size),
    );

    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 3)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: image ?? _InitialLabel(initial: initial, size: size),
    );

    if (!editable) return circle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.36,
            height: size * 0.36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_camera,
              size: size * 0.22,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialLabel extends StatelessWidget {
  const _InitialLabel({required this.initial, required this.size});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: AppTheme.display(
          size * 0.42,
          color: Colors.white,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
