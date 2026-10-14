import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A row of selectable line-color swatches. [disabledColors] renders a
/// swatch inert (e.g. already claimed by the other player).
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.disabledColors = const [],
  });

  final Color selected;
  final ValueChanged<Color> onChanged;
  final List<Color> disabledColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppColors.playerColors.map((color) {
        final isSelected = color.toARGB32() == selected.toARGB32();
        final isDisabled = disabledColors.any(
          (c) => c.toARGB32() == color.toARGB32(),
        );
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: isDisabled ? null : () => onChanged(color),
            child: Opacity(
              opacity: isDisabled ? 0.3 : 1,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2.5)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
