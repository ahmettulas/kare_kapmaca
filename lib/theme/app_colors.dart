import 'package:flutter/material.dart';

import 'theme_presets.dart';

/// Central color palette for Kare Kapmaca. Values are mutable (not
/// `const`) so a [ThemePreset] picked in Settings > Theme can recolor
/// the whole app at runtime — see [AppColors.apply].
class AppColors {
  AppColors._();

  static String currentThemeId = kThemePresets.first.id;

  /// Whether the current theme uses the premium AAA space UI language.
  /// See [ThemePreset.isPremium].
  static bool isPremium = kThemePresets.first.isPremium;

  /// Full-screen background photo for the current theme, if any.
  /// See [ThemePreset.backgroundImagePath].
  static String? backgroundImagePath = kThemePresets.first.backgroundImagePath;

  static Color background = kThemePresets.first.background;
  static Color backgroundGradientEnd = kThemePresets.first.backgroundGradientEnd;
  static Color surface = kThemePresets.first.surface;
  static Color surfaceRaised = kThemePresets.first.surfaceRaised;
  static Color border = kThemePresets.first.border;
  static Color glow = kThemePresets.first.glow;

  static Color textPrimary = kThemePresets.first.textPrimary;
  static Color textSecondary = kThemePresets.first.textSecondary;
  static Color textMuted = kThemePresets.first.textMuted;
  static Color textDisabled = kThemePresets.first.textDisabled;

  static Color gold = kThemePresets.first.gold;
  static Color blue = kThemePresets.first.blue;
  static Color green = kThemePresets.first.green;
  static Color orange = kThemePresets.first.orange;
  static Color red = kThemePresets.first.red;
  static Color purple = kThemePresets.first.purple;
  static Color cyan = kThemePresets.first.cyan;

  /// Selectable line/player colors, in the order shown in the mockup.
  static List<Color> playerColors = kThemePresets.first.playerColors;

  /// Repaints every [AppColors] field from [preset]. Call this whenever
  /// the selected theme changes (see `SettingsService.setThemeId`).
  static void apply(ThemePreset preset) {
    currentThemeId = preset.id;
    isPremium = preset.isPremium;
    backgroundImagePath = preset.backgroundImagePath;
    background = preset.background;
    backgroundGradientEnd = preset.backgroundGradientEnd;
    surface = preset.surface;
    surfaceRaised = preset.surfaceRaised;
    border = preset.border;
    glow = preset.glow;
    textPrimary = preset.textPrimary;
    textSecondary = preset.textSecondary;
    textMuted = preset.textMuted;
    textDisabled = preset.textDisabled;
    gold = preset.gold;
    blue = preset.blue;
    green = preset.green;
    orange = preset.orange;
    red = preset.red;
    purple = preset.purple;
    cyan = preset.cyan;
    playerColors = preset.playerColors;
  }
}
