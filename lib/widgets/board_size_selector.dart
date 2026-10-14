import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/board_size.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'custom_board_size_dialog.dart';

/// Lets the player pick the dot-grid size (4x4, 6x6, 8x8, or a custom
/// width/height) with a small dot preview per preset, mirroring the
/// mockup's size picker cards.
class BoardSizeSelector extends StatelessWidget {
  const BoardSizeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BoardSize selected;
  final ValueChanged<BoardSize> onChanged;

  Future<void> _openCustomDialog(BuildContext context) async {
    final result = await showDialog<BoardSize>(
      context: context,
      builder: (_) => CustomBoardSizeDialog(
        initial: selected.isPreset ? null : selected,
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    final isCustomActive = !selected.isPreset;

    return Row(
      children: [
        for (final preset in BoardSize.presets)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SizeTile(
                selected: !isCustomActive && selected.matches(preset),
                onTap: () => onChanged(preset),
                label: '${preset.dotsWide}x${preset.dotsHigh}',
                child: _DotPreview(
                  dots: preset.dotsWide,
                  active: !isCustomActive && selected.matches(preset),
                ),
              ),
            ),
          ),
        Expanded(
          child: _SizeTile(
            selected: isCustomActive,
            onTap: () => _openCustomDialog(context),
            label: isCustomActive ? selected.label : t.customSizeLabel,
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: isCustomActive ? AppColors.blue : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _SizeTile extends StatelessWidget {
  const _SizeTile({
    required this.selected,
    required this.onTap,
    required this.child,
    required this.label,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 34, child: Center(child: child)),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.body(
                12,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPreview extends StatelessWidget {
  const _DotPreview({required this.dots, required this.active});

  final int dots;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blue : AppColors.textMuted;
    final previewDots = dots > 6 ? 4 : dots;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(previewDots, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(previewDots, (col) {
            return Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            );
          }),
        );
      }),
    );
  }
}
