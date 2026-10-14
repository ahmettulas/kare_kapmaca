import 'package:flutter/foundation.dart' show Uint8List, compute;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/player_profile.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'avatar_circle.dart';
import 'color_swatch_picker.dart';

// image_picker's maxWidth/imageQuality only shrinks JPEG sources — a PNG
// (the common gallery format on web/desktop) is resized but re-encoded
// uncompressed, easily blowing past the room doc's avatar size budget (see
// RoomService._maxAvatarB64Length). Re-encoding to JPEG ourselves keeps the
// synced avatar small on every platform, regardless of the source format.
Uint8List _compressAvatar(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final resized = decoded.width > 800
      ? img.copyResize(decoded, width: 800)
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

/// Editable card for one local player: avatar (from gallery), name, and
/// line color. Used on the "Oda Kur" and "Aynı Telefon" setup screens.
class PlayerSetupCard extends StatelessWidget {
  const PlayerSetupCard({
    super.key,
    required this.label,
    required this.profile,
    required this.onChanged,
    this.disabledColors = const [],
  });

  final String label;
  final PlayerProfile profile;
  final ValueChanged<PlayerProfile> onChanged;
  final List<Color> disabledColors;

  Future<void> _pickAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final compressed = await compute(_compressAvatar, bytes);
        onChanged(
          profile.copyWith(avatarPath: picked.path, avatarBytes: compressed),
        );
      }
    } catch (e) {
      // Gallery unavailable (e.g. simulator without photos or denied
      // permission) — player simply keeps their color-fill avatar.
      debugPrint('PlayerSetupCard: avatar pick failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: profile.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.body(
                13,
                color: AppColors.textSecondary,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: AvatarCircle(
                  name: profile.name,
                  color: profile.color,
                  avatarPath: profile.avatarPath,
                  editable: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: profile.name)
                    ..selection = TextSelection.collapsed(
                      offset: profile.name.length,
                    ),
                  onChanged: (value) =>
                      onChanged(profile.copyWith(name: value)),
                  style: AppTheme.body(
                    15,
                    color: AppColors.textPrimary,
                    weight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: t.nameHint,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          t.lineColorLabel,
          style: AppTheme.body(
            13,
            color: AppColors.textSecondary,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ColorSwatchPicker(
          selected: profile.color,
          disabledColors: disabledColors,
          onChanged: (color) => onChanged(profile.copyWith(color: color)),
        ),
      ],
    );
  }
}
