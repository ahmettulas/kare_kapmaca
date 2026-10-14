import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/theme_presets.dart';

/// Simple persisted app preferences (sound / music / haptics toggles,
/// UI language, selected color theme).
class SettingsService extends ChangeNotifier {
  static const _soundKey = 'sound_enabled';
  static const _musicKey = 'music_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _languageKey = 'app_language';
  static const _themeKey = 'app_theme_id';

  SharedPreferences? _prefs;

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;
  AppLanguage language = AppLanguage.en;
  String themeId = kThemePresets.first.id;

  AppStrings get strings =>
      language == AppLanguage.tr ? AppStrings.tr : AppStrings.en;

  ThemePreset get themePreset => kThemePresets.firstWhere(
        (preset) => preset.id == themeId,
        orElse: () => kThemePresets.first,
      );

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    soundEnabled = _prefs!.getBool(_soundKey) ?? true;
    musicEnabled = _prefs!.getBool(_musicKey) ?? true;
    hapticsEnabled = _prefs!.getBool(_hapticsKey) ?? true;
    language = _prefs!.getString(_languageKey) == 'tr'
        ? AppLanguage.tr
        : AppLanguage.en;
    themeId = _prefs!.getString(_themeKey) ?? kThemePresets.first.id;
    AppColors.apply(themePreset);
    notifyListeners();
  }

  Future<void> setThemeId(String id) async {
    themeId = id;
    AppColors.apply(themePreset);
    notifyListeners();
    (_prefs ??= await SharedPreferences.getInstance()).setString(
      _themeKey,
      id,
    );
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    (_prefs ??= await SharedPreferences.getInstance()).setBool(
      _soundKey,
      value,
    );
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    notifyListeners();
    (_prefs ??= await SharedPreferences.getInstance()).setBool(
      _musicKey,
      value,
    );
  }

  Future<void> setHapticsEnabled(bool value) async {
    hapticsEnabled = value;
    notifyListeners();
    (_prefs ??= await SharedPreferences.getInstance()).setBool(
      _hapticsKey,
      value,
    );
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    notifyListeners();
    (_prefs ??= await SharedPreferences.getInstance()).setString(
      _languageKey,
      value == AppLanguage.tr ? 'tr' : 'en',
    );
  }
}
