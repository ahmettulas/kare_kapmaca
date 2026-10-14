import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Fixed brand gradients for the premium AAA button/panel language.
/// Unlike [AppColors], these are exact spec colors and don't change
/// with the selected player-color theme.
class AppGradients {
  AppGradients._();

  /// Maps a semantic [AppColors] accent (blue/green/orange/purple) to
  /// its matching premium button gradient. Falls back to a flat
  /// gradient of [color] itself for anything else (e.g. red).
  static LinearGradient forColor(Color color) {
    if (color == AppColors.blue) return primaryBlue;
    if (color == AppColors.green) return secondaryGreen;
    if (color == AppColors.orange) return warmOrange;
    if (color == AppColors.purple) return royalPurple;
    return LinearGradient(colors: [color, color]);
  }

  static const LinearGradient primaryBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A9EFF), Color(0xFF2D6BFF)],
  );

  static const LinearGradient secondaryGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4BEA74), Color(0xFF1DB954)],
  );

  static const LinearGradient warmOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFC248), Color(0xFFF39C12)],
  );

  static const LinearGradient royalPurple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA76DFF), Color(0xFF7A3FFF)],
  );
}
