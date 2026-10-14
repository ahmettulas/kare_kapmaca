import 'package:flutter/material.dart';

/// A full color palette the player can pick from Settings > Theme.
///
/// Add new presets to [kThemePresets] — everything else (the picker UI,
/// persistence, and applying it across the app) already wires itself up.
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.nameEn,
    required this.nameTr,
    required this.background,
    required this.backgroundGradientEnd,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.glow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.gold,
    required this.blue,
    required this.green,
    required this.orange,
    required this.red,
    required this.purple,
    required this.cyan,
    this.isPremium = false,
    this.backgroundImagePath,
  });

  final String id;
  final String nameEn;
  final String nameTr;

  /// Whether this theme uses the premium AAA space UI language (Poppins
  /// type, glassmorphism panels, gradient/glow buttons, procedural
  /// cinematic backdrop) instead of the app's original flat look.
  final bool isPremium;

  /// Optional full-screen background photo. When set, this is painted
  /// behind every screen instead of the procedural `SpaceBackground`.
  final String? backgroundImagePath;

  final Color background;
  final Color backgroundGradientEnd;
  final Color surface;
  final Color surfaceRaised;
  final Color border;

  /// Neon accent used for glow/bloom effects on premium buttons and icons.
  final Color glow;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  final Color gold;
  final Color blue;
  final Color green;
  final Color orange;
  final Color red;
  final Color purple;
  final Color cyan;

  /// Selectable line/player colors, in the order shown across the app.
  List<Color> get playerColors => [blue, red, green, purple, orange, cyan];

  String name(bool isTurkish) => isTurkish ? nameTr : nameEn;
}

/// Built-in theme presets. The first entry is the app's default look
/// (used until the player changes it in Settings); more presets can
/// simply be appended here.
const List<ThemePreset> kThemePresets = [
  // AAA premium space UI — deep-space palette, glow accents, the
  // user-provided space photo as backdrop. Default theme.
  ThemePreset(
    id: 'space',
    nameEn: 'Space',
    nameTr: 'Uzay',
    isPremium: true,
    backgroundImagePath: 'assets/themes/space.webp',
    background: Color(0xFF050A16),
    backgroundGradientEnd: Color(0xFF0B1325),
    surface: Color(0xFF111B2F),
    surfaceRaised: Color(0xFF162238),
    border: Color(0xFF274E8A),
    glow: Color(0xFF3B82F6),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFC7D4F4),
    textMuted: Color(0xFF9AA7C7),
    textDisabled: Color(0xFF5B6785),
    gold: Color(0xFFFFC94A),
    blue: Color(0xFF3A86FF),
    green: Color(0xFF32D66B),
    orange: Color(0xFFFFB020),
    red: Color(0xFFFF4D5A),
    purple: Color(0xFF8B5CF6),
    cyan: Color(0xFF34C3D6),
  ),
  ThemePreset(
    id: 'classic',
    nameEn: 'Classic',
    nameTr: 'Klasik',
    background: Color(0xFF0D1526),
    backgroundGradientEnd: Color(0xFF121B33),
    surface: Color(0xFF161F38),
    surfaceRaised: Color(0xFF1C2745),
    border: Color(0xFF2A3559),
    glow: Color(0xFF2F6FED),
    textPrimary: Color(0xFFF4F6FB),
    textSecondary: Color(0xFF8B93AC),
    textMuted: Color(0xFF5B6482),
    textDisabled: Color(0xFF4A5578),
    gold: Color(0xFFF5B942),
    blue: Color(0xFF2F6FED),
    green: Color(0xFF2FAE60),
    orange: Color(0xFFF2994A),
    red: Color(0xFFE5484D),
    purple: Color(0xFF8E6FF7),
    cyan: Color(0xFF34C3D6),
  ),
  // Deep woodland palette — moss, bark, and dappled-light accents, with
  // the user-provided forest photo as backdrop.
  ThemePreset(
    id: 'forest',
    nameEn: 'Forest',
    nameTr: 'Orman',
    isPremium: true,
    backgroundImagePath: 'assets/themes/forest.webp',
    background: Color(0xFF0C160F),
    backgroundGradientEnd: Color(0xFF112014),
    surface: Color(0xFF16261A),
    surfaceRaised: Color(0xFF1D3123),
    border: Color(0xFF2E4B34),
    glow: Color(0xFF4CAF6D),
    textPrimary: Color(0xFFF2F7EE),
    textSecondary: Color(0xFFC3D6C4),
    textMuted: Color(0xFF8FA893),
    textDisabled: Color(0xFF556B58),
    gold: Color(0xFFE0B44A),
    blue: Color(0xFF3E9BB8),
    green: Color(0xFF4CAF6D),
    orange: Color(0xFFC9793B),
    red: Color(0xFFD1584C),
    purple: Color(0xFF8A6FB0),
    cyan: Color(0xFF4FBFA8),
  ),
  // Icy, muted steel palette — the user-provided Game of Thrones photo
  // as backdrop.
  ThemePreset(
    id: 'got',
    nameEn: 'Game of Thrones',
    nameTr: 'Game of Thrones',
    isPremium: true,
    backgroundImagePath: 'assets/themes/GameOfThrones.webp',
    background: Color(0xFF0A0E13),
    backgroundGradientEnd: Color(0xFF10161D),
    surface: Color(0xFF161D26),
    surfaceRaised: Color(0xFF1E2733),
    border: Color(0xFF3A4756),
    glow: Color(0xFF7FA8C9),
    textPrimary: Color(0xFFEFF3F7),
    textSecondary: Color(0xFFB9C5D0),
    textMuted: Color(0xFF7C8A98),
    textDisabled: Color(0xFF4B5763),
    gold: Color(0xFFC9A24B),
    blue: Color(0xFF5B87AC),
    green: Color(0xFF5C8A6E),
    orange: Color(0xFFB56A3C),
    red: Color(0xFF8E3B3B),
    purple: Color(0xFF6E5C87),
    cyan: Color(0xFF4E97A0),
  ),
];
