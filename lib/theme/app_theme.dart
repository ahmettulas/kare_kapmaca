import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Titles / display text. Poppins ExtraBold for the premium (Uzay)
  /// theme, Baloo2 Bold for the original Classic look.
  static TextStyle display(
    double size, {
    Color? color,
    FontWeight? weight,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    final premium = AppColors.isPremium;
    final fontFn = premium ? GoogleFonts.poppins : GoogleFonts.baloo2;
    return fontFn(
      fontSize: size,
      fontWeight: weight ?? (premium ? FontWeight.w800 : FontWeight.w700),
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  /// Body copy. Poppins for the premium (Uzay) theme, Nunito for Classic.
  static TextStyle body(double size, {Color? color, FontWeight? weight}) {
    final premium = AppColors.isPremium;
    final fontFn = premium ? GoogleFonts.poppins : GoogleFonts.nunito;
    return fontFn(
      fontSize: size,
      fontWeight: weight ?? (premium ? FontWeight.w500 : FontWeight.w600),
      color: color ?? AppColors.textPrimary,
    );
  }

  /// Bold, all-caps-friendly button label style — premium (Uzay) theme only.
  static TextStyle button(double size, {Color color = Colors.white}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.4,
    );
  }

  /// Soft neon text glow — layer behind a title's normal shadow list.
  /// Premium (Uzay) theme only.
  static List<Shadow> glow(Color color, {double blur = 18}) {
    return [
      Shadow(color: color.withValues(alpha: 0.65), blurRadius: blur),
      Shadow(
        color: Colors.black.withValues(alpha: 0.55),
        offset: const Offset(0, 3),
        blurRadius: 6,
      ),
    ];
  }

  /// Soft outer bloom for buttons/icons/panels — a glow-colored
  /// [BoxShadow] plus a small ambient contact shadow. Premium theme only.
  static List<BoxShadow> outerGlow(Color color, {double blur = 24, double spread = 0}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.45),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        offset: const Offset(0, 6),
        blurRadius: 14,
      ),
    ];
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final hasCustomBackdrop = AppColors.isPremium || AppColors.backgroundImagePath != null;
    final fontTextTheme = AppColors.isPremium
        ? GoogleFonts.poppinsTextTheme(base.textTheme)
        : GoogleFonts.nunitoTextTheme(base.textTheme);
    return base.copyWith(
      // Transparent when the theme paints its own backdrop (procedural
      // space scene or a photo) via MaterialApp.builder, so it shows
      // through every Scaffold. Classic keeps its plain solid color.
      scaffoldBackgroundColor: hasCustomBackdrop ? Colors.transparent : AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.blue,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      textTheme: fontTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
