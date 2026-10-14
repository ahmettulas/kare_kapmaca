import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../game_logic/edge.dart';
import '../game_logic/game_engine.dart';
import '../models/player_profile.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import 'avatar_circle.dart';

/// Renders the dot grid, claimed lines and captured boxes, and turns
/// taps near a line segment into [GameEngine.claimEdge] calls. Supports
/// rectangular (non-square) grids.
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.engine,
    required this.players,
    this.interactive = true,
    this.onRemoteMove,
  });

  final GameEngine engine;
  final List<PlayerProfile> players;
  final bool interactive;

  /// When set (online games), taps don't claim the edge locally — they're
  /// sent here instead, and the move is applied once it comes back through
  /// the room's move stream so both players stay in sync.
  final ValueChanged<EdgeId>? onRemoteMove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: engine.boxesWide / engine.boxesHigh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const padding = 18.0;
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final spacingX = (width - padding * 2) / (engine.dotsWide - 1);
          final spacingY = (height - padding * 2) / (engine.dotsHigh - 1);

          void handleTap(Offset local) {
            if (!interactive || engine.isGameOver) return;
            final x = local.dx - padding;
            final y = local.dy - padding;
            final edge = _nearestEdge(x, y, spacingX, spacingY);
            if (edge == null || engine.isEdgeClaimed(edge)) return;

            if (onRemoteMove != null) {
              onRemoteMove!(edge);
              return;
            }

            final boxesBefore = engine.boxesClaimed;
            if (!engine.claimEdge(edge)) return;

            final settings = context.read<SettingsService>();
            final audio = context.read<AudioService>();
            final boxCompleted = engine.boxesClaimed > boxesBefore;
            audio.playSfx(
              boxCompleted ? SfxEvent.boxComplete : SfxEvent.placement,
              enabled: settings.soundEnabled,
            );
            if (boxCompleted && settings.hapticsEnabled) {
              HapticFeedback.selectionClick();
            }
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => handleTap(details.localPosition),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BoardPainter(
                      engine: engine,
                      players: players,
                      padding: padding,
                      spacingX: spacingX,
                      spacingY: spacingY,
                    ),
                  ),
                ),
                ..._buildBoxOverlays(padding, spacingX, spacingY),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBoxOverlays(double padding, double spacingX, double spacingY) {
    final widgets = <Widget>[];
    for (var row = 0; row < engine.boxesHigh; row++) {
      for (var col = 0; col < engine.boxesWide; col++) {
        final owner = engine.boxOwnerAt(row, col);
        if (owner == -1) continue;
        final profile = players[owner];
        if (!profile.hasAvatar) continue;
        final image = buildAvatarImage(
          avatarBytes: profile.avatarBytes,
          avatarPath: profile.avatarPath,
          fit: BoxFit.cover,
          errorBuilder: () => const SizedBox.shrink(),
        );
        if (image == null) continue;
        final left = padding + col * spacingX + 2;
        final top = padding + row * spacingY + 2;
        widgets.add(
          Positioned(
            left: left,
            top: top,
            width: spacingX - 4,
            height: spacingY - 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: image,
            ),
          ),
        );
      }
    }
    return widgets;
  }

  EdgeId? _nearestEdge(double x, double y, double spacingX, double spacingY) {
    final dotsWide = engine.dotsWide;
    final dotsHigh = engine.dotsHigh;
    final tolerance = math.min(spacingX, spacingY) * 0.32;

    // Nearest horizontal edge candidate.
    final hRow = (y / spacingY).round().clamp(0, dotsHigh - 1);
    final hCol = (x / spacingX).floor().clamp(0, dotsWide - 2);
    final hDist = (y - hRow * spacingY).abs();
    final hWithinSpan = x >= hCol * spacingX - tolerance &&
        x <= (hCol + 1) * spacingX + tolerance;

    // Nearest vertical edge candidate.
    final vCol = (x / spacingX).round().clamp(0, dotsWide - 1);
    final vRow = (y / spacingY).floor().clamp(0, dotsHigh - 2);
    final vDist = (x - vCol * spacingX).abs();
    final vWithinSpan = y >= vRow * spacingY - tolerance &&
        y <= (vRow + 1) * spacingY + tolerance;

    EdgeId? best;
    var bestDist = tolerance;

    if (hDist <= tolerance && hWithinSpan && hDist <= bestDist) {
      best = EdgeId(EdgeType.horizontal, hRow, hCol);
      bestDist = hDist;
    }
    if (vDist <= tolerance && vWithinSpan && vDist < bestDist) {
      best = EdgeId(EdgeType.vertical, vRow, vCol);
      bestDist = vDist;
    }
    return best;
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.engine,
    required this.players,
    required this.padding,
    required this.spacingX,
    required this.spacingY,
  });

  final GameEngine engine;
  final List<PlayerProfile> players;
  final double padding;
  final double spacingX;
  final double spacingY;

  @override
  void paint(Canvas canvas, Size size) {
    final dotsWide = engine.dotsWide;
    final dotsHigh = engine.dotsHigh;

    // Captured boxes.
    final boxPaint = Paint()..style = PaintingStyle.fill;
    for (var row = 0; row < engine.boxesHigh; row++) {
      for (var col = 0; col < engine.boxesWide; col++) {
        final owner = engine.boxOwnerAt(row, col);
        if (owner == -1) continue;
        final rect = Rect.fromLTWH(
          padding + col * spacingX + 2,
          padding + row * spacingY + 2,
          spacingX - 4,
          spacingY - 4,
        );
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
        boxPaint.color = players[owner].color.withValues(alpha: 0.55);
        canvas.drawRRect(rrect, boxPaint);
      }
    }

    // Edges (claimed only, for a clean uncluttered look).
    final linePaint = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (var row = 0; row < dotsHigh; row++) {
      for (var col = 0; col < dotsWide - 1; col++) {
        final id = EdgeId(EdgeType.horizontal, row, col);
        if (!engine.isEdgeClaimed(id)) continue;
        linePaint.color = players[engine.edgeOwner(id)].color;
        final y = padding + row * spacingY;
        canvas.drawLine(
          Offset(padding + col * spacingX, y),
          Offset(padding + (col + 1) * spacingX, y),
          linePaint,
        );
      }
    }
    for (var row = 0; row < dotsHigh - 1; row++) {
      for (var col = 0; col < dotsWide; col++) {
        final id = EdgeId(EdgeType.vertical, row, col);
        if (!engine.isEdgeClaimed(id)) continue;
        linePaint.color = players[engine.edgeOwner(id)].color;
        final x = padding + col * spacingX;
        canvas.drawLine(
          Offset(x, padding + row * spacingY),
          Offset(x, padding + (row + 1) * spacingY),
          linePaint,
        );
      }
    }

    // Dots on top.
    final dotPaint = Paint()..color = AppColors.textPrimary;
    final dotRadius = math.max(3.0, math.min(spacingX, spacingY) * 0.06);
    for (var row = 0; row < dotsHigh; row++) {
      for (var col = 0; col < dotsWide; col++) {
        canvas.drawCircle(
          Offset(padding + col * spacingX, padding + row * spacingY),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}
