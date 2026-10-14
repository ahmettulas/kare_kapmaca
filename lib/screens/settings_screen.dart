import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_presets.dart';
import '../widgets/screen_backdrop.dart';
import '../widgets/setup_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final t = settings.strings;

    return Scaffold(
      body: ScreenBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 6),
                SetupHeader(title: t.settingsScreenTitle),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      _SettingsTile(
                        icon: Icons.volume_up_rounded,
                        title: t.soundEffectsLabel,
                        value: settings.soundEnabled,
                        onChanged: (v) =>
                            context.read<SettingsService>().setSoundEnabled(v),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.music_note_rounded,
                        title: t.musicLabel,
                        value: settings.musicEnabled,
                        onChanged: (v) {
                          context.read<SettingsService>().setMusicEnabled(v);
                          context.read<AudioService>().setMusicEnabled(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.vibration_rounded,
                        title: t.hapticsLabel,
                        value: settings.hapticsEnabled,
                        onChanged: (v) => context
                            .read<SettingsService>()
                            .setHapticsEnabled(v),
                      ),
                      const SizedBox(height: 12),
                      _ThemeTile(
                        title: t.themeLabel,
                        currentThemeName: settings.themePreset.name(
                          settings.language == AppLanguage.tr,
                        ),
                        onTap: () => _showThemeSheet(context, settings, t),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.languageLabel,
                        style: AppTheme.body(
                          13,
                          color: AppColors.textSecondary,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _LanguageOption(
                              label: t.languageEnglish,
                              selected: settings.language == AppLanguage.en,
                              onTap: () => context
                                  .read<SettingsService>()
                                  .setLanguage(AppLanguage.en),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LanguageOption(
                              label: t.languageTurkish,
                              selected: settings.language == AppLanguage.tr,
                              onTap: () => context
                                  .read<SettingsService>()
                                  .setLanguage(AppLanguage.tr),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          t.versionFooter,
                          style: AppTheme.body(
                            12,
                            color: AppColors.textMuted,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showThemeSheet(
  BuildContext context,
  SettingsService settings,
  AppStrings t,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.themeSheetTitle,
                style: AppTheme.display(18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              for (final preset in kThemePresets) ...[
                _ThemeOptionRow(
                  preset: preset,
                  isTurkish: settings.language == AppLanguage.tr,
                  selected: settings.themeId == preset.id,
                  onTap: () {
                    settings.setThemeId(preset.id);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTheme.body(
                14,
                color: AppColors.textPrimary,
                weight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.blue,
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.currentThemeName,
    required this.onTap,
  });

  final String title;
  final String currentThemeName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.palette_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTheme.body(
                  14,
                  color: AppColors.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              currentThemeName,
              style: AppTheme.body(
                13,
                color: AppColors.textSecondary,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.preset,
    required this.isTurkish,
    required this.selected,
    required this.onTap,
  });

  final ThemePreset preset;
  final bool isTurkish;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            preset.backgroundImagePath != null
                ? ClipOval(
                    child: Image.asset(
                      preset.backgroundImagePath!,
                      width: 16,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  )
                : _ColorDot(preset.background, border: true),
            const SizedBox(width: 4),
            _ColorDot(preset.blue),
            const SizedBox(width: 4),
            _ColorDot(preset.gold),
            const SizedBox(width: 4),
            _ColorDot(preset.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                preset.name(isTurkish),
                style: AppTheme.body(
                  14,
                  color: AppColors.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.blue, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.color, {this.border = false});

  final Color color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: AppColors.border) : null,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.body(
              14,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
