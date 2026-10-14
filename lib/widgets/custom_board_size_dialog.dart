import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/board_size.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

const _maxDots = 20;

/// Dialog letting the player type a custom dot-grid width/height. Only
/// digits are accepted and values below [BoardSize.minDots] are rejected.
class CustomBoardSizeDialog extends StatefulWidget {
  const CustomBoardSizeDialog({super.key, this.initial});

  final BoardSize? initial;

  @override
  State<CustomBoardSizeDialog> createState() => _CustomBoardSizeDialogState();
}

class _CustomBoardSizeDialogState extends State<CustomBoardSizeDialog> {
  late final TextEditingController _widthController = TextEditingController(
    text: widget.initial != null ? '${widget.initial!.dotsWide}' : '',
  );
  late final TextEditingController _heightController = TextEditingController(
    text: widget.initial != null ? '${widget.initial!.dotsHigh}' : '',
  );

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  int? _parse(String text) {
    final value = int.tryParse(text);
    if (value == null || value < BoardSize.minDots || value > _maxDots) {
      return null;
    }
    return value;
  }

  void _submit() {
    final width = _parse(_widthController.text);
    final height = _parse(_heightController.text);
    if (width == null || height == null) return;
    playButtonSfx(context);
    Navigator.of(context).pop(BoardSize(width, height));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsService>().strings;
    return AlertDialog(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        t.customSizeDialogTitle,
        style: AppTheme.display(18, color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.customSizeDialogHint(BoardSize.minDots, _maxDots),
            style: AppTheme.body(13, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DotCountField(
                  label: t.widthLabel,
                  controller: _widthController,
                ),
              ),
              const SizedBox(width: 14),
              Text('x', style: AppTheme.display(18, color: AppColors.textMuted)),
              const SizedBox(width: 14),
              Expanded(
                child: _DotCountField(
                  label: t.heightLabel,
                  controller: _heightController,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            playButtonSfx(context);
            Navigator.of(context).pop();
          },
          child: Text(
            t.cancelLabel,
            style: AppTheme.body(14, color: Colors.white),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _widthController,
          builder: (context, widthValue, _) {
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: _heightController,
              builder: (context, heightValue, _) {
                final isValid = _parse(widthValue.text) != null &&
                    _parse(heightValue.text) != null;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surface,
                    disabledForegroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isValid ? _submit : null,
                  child: Text(
                    t.applyLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _DotCountField extends StatelessWidget {
  const _DotCountField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body(
            11,
            color: AppColors.textMuted,
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: AppTheme.display(18, color: Colors.white),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              hintText: '—',
            ),
          ),
        ),
      ],
    );
  }
}
