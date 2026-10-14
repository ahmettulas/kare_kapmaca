import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Procedurally painted deep-space scene: nebula clouds, a ringed
/// planet, a glowing Earth-like planet with a sunrise rim, a twinkling
/// star field, a distant asteroid field and a couple of comets.
///
/// Painted once behind the whole app (see `main.dart`'s `MaterialApp
/// .builder`) so every screen shares the same cinematic backdrop.
class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;
  late final List<_Asteroid> _asteroids;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _stars = List.generate(140, (i) {
      return _Star(
        dx: rng.nextDouble(),
        dy: rng.nextDouble(),
        radius: 0.6 + rng.nextDouble() * 1.6,
        baseOpacity: 0.25 + rng.nextDouble() * 0.55,
        twinkleSpeed: 0.4 + rng.nextDouble() * 1.1,
        phase: rng.nextDouble() * math.pi * 2,
      );
    });
    _asteroids = List.generate(9, (i) {
      return _Asteroid(
        dx: rng.nextDouble(),
        scale: 0.5 + rng.nextDouble() * 1.0,
        rotation: rng.nextDouble() * math.pi * 2,
        seed: rng.nextInt(9999),
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _SpacePainter(
            time: _ctrl.value * math.pi * 2,
            stars: _stars,
            asteroids: _asteroids,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.phase,
  });

  final double dx;
  final double dy;
  final double radius;
  final double baseOpacity;
  final double twinkleSpeed;
  final double phase;
}

class _Asteroid {
  _Asteroid({
    required this.dx,
    required this.scale,
    required this.rotation,
    required this.seed,
  });

  final double dx;
  final double scale;
  final double rotation;
  final int seed;
}

class _SpacePainter extends CustomPainter {
  _SpacePainter({required this.time, required this.stars, required this.asteroids});

  final double time;
  final List<_Star> stars;
  final List<_Asteroid> asteroids;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    _paintBaseGradient(canvas, rect);
    _paintNebula(canvas, size);
    _paintVolumetricLight(canvas, size);
    _paintStars(canvas, size);
    _paintRingedPlanet(canvas, size);
    _paintGlowPlanet(canvas, size);
    _paintComets(canvas, size);
    _paintAsteroidField(canvas, size);
  }

  void _paintBaseGradient(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF050A16), Color(0xFF0B1325), Color(0xFF050A16)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintNebula(Canvas canvas, Size size) {
    void blob(Offset center, double radius, Color color, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(center, radius, paint);
    }

    blob(
      Offset(size.width * 0.18, size.height * 0.28),
      size.width * 0.62,
      const Color(0xFF8B5CF6),
      0.22,
    );
    blob(
      Offset(size.width * 0.92, size.height * 0.55),
      size.width * 0.55,
      const Color(0xFF3B82F6),
      0.20,
    );
    blob(
      Offset(size.width * 0.65, size.height * 0.92),
      size.width * 0.5,
      const Color(0xFF3B1E6E),
      0.16,
    );
  }

  void _paintVolumetricLight(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.10),
          const Color(0xFF3B82F6).withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, -size.height * 0.05),
          radius: size.width * 0.9,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final star in stars) {
      final twinkle = 0.5 + 0.5 * math.sin(time * star.twinkleSpeed + star.phase);
      final opacity = (star.baseOpacity * (0.55 + 0.45 * twinkle)).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  void _paintRingedPlanet(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.22, size.height * 0.16);
    final planetRadius = size.width * 0.16;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.32);

    // Ring — back half.
    final ringRect = Rect.fromCenter(
      center: Offset.zero,
      width: planetRadius * 3.1,
      height: planetRadius * 1.05,
    );
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = planetRadius * 0.16
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF2C879).withValues(alpha: 0.05),
          const Color(0xFFF2C879).withValues(alpha: 0.55),
          const Color(0xFFF2C879).withValues(alpha: 0.05),
        ],
      ).createShader(ringRect);
    canvas.drawArc(ringRect, math.pi * 0.08, math.pi * 0.84, false, ringPaint);

    canvas.restore();

    // Planet body.
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        colors: const [Color(0xFF9E7B4F), Color(0xFF4A3A28), Color(0xFF241B14)],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: planetRadius));
    canvas.drawCircle(center, planetRadius, bodyPaint);

    // Rim light.
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFFFD9A0).withValues(alpha: 0.6),
          Colors.transparent,
        ],
        stops: const [0.55, 0.68, 0.85],
      ).createShader(Rect.fromCircle(center: center, radius: planetRadius));
    canvas.drawCircle(center, planetRadius - 1, rimPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.32);
    // Ring — front half (drawn over the planet).
    final frontRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = planetRadius * 0.16
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF2C879).withValues(alpha: 0.05),
          const Color(0xFFF2C879).withValues(alpha: 0.75),
          const Color(0xFFF2C879).withValues(alpha: 0.05),
        ],
      ).createShader(ringRect);
    canvas.drawArc(ringRect, math.pi * 1.08, math.pi * 0.84, false, frontRingPaint);
    canvas.restore();
  }

  void _paintGlowPlanet(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.7);
    final radius = size.width * 0.22;

    // Sunrise glow behind the planet.
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB020).withValues(alpha: 0.35),
          const Color(0xFFFFB020).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2.1))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius * 2.1, glowPaint);

    // Planet body.
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        colors: const [
          Color(0xFF6FB8FF),
          Color(0xFF2D6BFF),
          Color(0xFF0B1F4D),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    // Orange sunrise rim on the lower-left edge.
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          Colors.transparent,
          Color(0xFFFFB020),
          Colors.transparent,
        ],
        stops: const [0.62, 0.72, 0.85],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius - 1.5, rimPaint);
  }

  void _paintComets(Canvas canvas, Size size) {
    void comet(Offset head, double length, double angle, double opacity) {
      final tail = Offset(
        head.dx - math.cos(angle) * length,
        head.dy - math.sin(angle) * length,
      );
      final paint = Paint()
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromPoints(head, tail));
      canvas.drawLine(tail, head, paint);

      final dotPaint = Paint()..color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(head, 2.2, dotPaint);
    }

    final twinkle1 = 0.5 + 0.5 * math.sin(time * 0.3);
    comet(
      Offset(size.width * 0.7, size.height * 0.12),
      size.width * 0.22,
      math.pi * 0.82,
      0.35 + 0.25 * twinkle1,
    );
    comet(
      Offset(size.width * 0.12, size.height * 0.52),
      size.width * 0.14,
      math.pi * 0.2,
      0.28,
    );
  }

  void _paintAsteroidField(Canvas canvas, Size size) {
    for (final rock in asteroids) {
      final rng = math.Random(rock.seed);
      final baseRadius = size.width * 0.028 * rock.scale;
      final center = Offset(
        rock.dx * size.width,
        size.height * (0.93 + rng.nextDouble() * 0.08),
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rock.rotation);

      final path = Path();
      const sides = 7;
      for (var i = 0; i < sides; i++) {
        final a = (i / sides) * math.pi * 2;
        final r = baseRadius * (0.7 + rng.nextDouble() * 0.5);
        final p = Offset(math.cos(a) * r, math.sin(a) * r);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();

      final fillPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A3F52), Color(0xFF14192A)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: baseRadius));
      canvas.drawPath(path, fillPaint);

      final edgePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.08);
      canvas.drawPath(path, edgePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) => true;
}
