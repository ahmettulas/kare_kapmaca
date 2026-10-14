import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _navigated = false;

  // mark-area: opacity/scale/blur
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _markBlur;

  // shine: translateX (-1.1 → 1.1 of its own width) and opacity
  late final Animation<double> _shineX;
  late final Animation<double> _shineOpacity;

  // accent: opacity with flicker
  late final Animation<double> _accentOpacity;

  // powered footer: opacity and translateY
  late final Animation<double> _poweredOpacity;
  late final Animation<double> _poweredY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5400),
    );

    // mark-area animations
    _markOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 14),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 8),
    ]).animate(_ctrl);

    _markScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.985, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 14),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.01).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.01), weight: 8),
    ]).animate(_ctrl);

    _markBlur = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 14),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 3.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(3.0), weight: 8),
    ]).animate(_ctrl);

    // shine sweep: 0–24% hidden, 24–56% sweep, 56–100% hidden
    _shineX = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(-1.1), weight: 24),
      TweenSequenceItem(tween: Tween(begin: -1.1, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)), weight: 32),
      TweenSequenceItem(tween: ConstantTween(1.1), weight: 44),
    ]).animate(_ctrl);

    _shineOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 24),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)), weight: 8),
      TweenSequenceItem(tween: ConstantTween(0.9), weight: 24),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 6),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 38),
    ]).animate(_ctrl);

    // accent flicker: 0–18% hidden, 18–27% flicker, 27–72% visible, 72–100% fade
    _accentOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4).chain(CurveTween(curve: Curves.easeInOut)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 3),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 8),
    ]).animate(_ctrl);

    // powered footer: 0–38% hidden, 38–54% fade-in+rise, 54–72% hold, 72–92% fade-out
    _poweredOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 38),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 16),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 8),
    ]).animate(_ctrl);

    _poweredY = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(6.0), weight: 38),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 16),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 46),
    ]).animate(_ctrl);

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goHome();
    });

    _ctrl.forward();
  }

  void _goHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainMenuScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion) return _buildReducedMotion();

    return GestureDetector(
      onTap: () {
        _ctrl.stop();
        _goHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF02030A),
        body: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => _buildScene(context),
        ),
      ),
    );
  }

  Widget _buildScene(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final markWidth = size.width * 0.88;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background radial gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0.1),
              radius: 1.0,
              colors: [Color(0xFF0A1119), Color(0xFF04070B), Color(0xFF02030A)],
              stops: [0.0, 0.75, 1.0],
            ),
          ),
        ),

        // Blue X-accent diagonals (behind mark)
        Positioned(
          left: 0, right: 0,
          top: size.height * 0.42,
          child: Opacity(
            opacity: _accentOpacity.value.clamp(0.0, 1.0),
            child: Center(
              child: SizedBox(
                width: (size.width * 0.48).clamp(0, 640),
                height: (size.width * 0.48 * 120 / 200).clamp(0, 384),
                child: CustomPaint(painter: _AccentPainter()),
              ),
            ),
          ),
        ),

        // Mark area (ULX + INTERACTIVE)
        Positioned(
          left: (size.width - markWidth) / 2,
          top: size.height * 0.42,
          width: markWidth,
          child: Transform.scale(
            scale: _markScale.value,
            alignment: Alignment.center,
            child: Opacity(
              opacity: _markOpacity.value.clamp(0.0, 1.0),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: _markBlur.value,
                  sigmaY: _markBlur.value,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildUlxWordmark(markWidth),
                    const SizedBox(height: 8),
                    _buildSubhead(markWidth),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Powered-by footer
        Positioned(
          left: 0, right: 0,
          bottom: size.height * 0.14,
          child: Transform.translate(
            offset: Offset(0, _poweredY.value),
            child: Opacity(
              opacity: _poweredOpacity.value.clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'POWERED BY',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w500,
                      fontSize: (size.width * 0.011).clamp(8, 14),
                      letterSpacing: 0.45 * (size.width * 0.011).clamp(8, 14),
                      color: const Color(0x73DCE1EB),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ULX INTERACTIVE',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w700,
                      fontSize: (size.width * 0.017).clamp(11, 22),
                      letterSpacing: 0.42 * (size.width * 0.017).clamp(11, 22),
                      color: const Color(0xD996BEFF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUlxWordmark(double containerWidth) {
    final fontSize = (containerWidth * 0.12).clamp(48.0, 200.0);

    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE6ECF5),
        Color(0xFFB1BBC8),
        Color(0xFF5A6373),
        Color(0xFFAAB4C2),
        Color(0xFFE6ECF5),
      ],
      stops: [0.0, 0.40, 0.55, 0.72, 1.0],
    );

    return ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Gradient text via ShaderMask
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'ULX',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
                letterSpacing: 0.02 * fontSize,
                height: 1.0,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Color(0xA6000000),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          // Shine sweep overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: _shineOpacity.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(containerWidth * _shineX.value, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        transform: const GradientRotation(105 * 3.1415926 / 180),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                        stops: const [0.38, 0.50, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubhead(double containerWidth) {
    final fontSize = (containerWidth * 0.026).clamp(13.0, 32.0);
    final lineLen = (containerWidth * 0.04).clamp(18.0, 64.0);
    final lineGap = (containerWidth * 0.014).clamp(8.0, 22.0);

    const lineDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, Color(0xB278A0FF), Colors.transparent],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: lineLen, height: 1, decoration: lineDecoration),
        SizedBox(width: lineGap),
        Text(
          'INTERACTIVE',
          style: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
            letterSpacing: 0.42 * fontSize,
            color: const Color(0xEBDCEBFF),
          ),
        ),
        SizedBox(width: lineGap),
        Container(width: lineLen, height: 1, decoration: lineDecoration),
      ],
    );
  }

  Widget _buildReducedMotion() {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1500)),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _goHome());
        }
        return Scaffold(
          backgroundColor: const Color(0xFF02030A),
          body: Center(
            child: AnimatedOpacity(
              opacity: snap.connectionState == ConnectionState.done ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Text(
                'ULX',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.w900,
                  fontSize: 72,
                  color: const Color(0xFFB1BBC8),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4D8DFF)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Map from SVG viewBox (-100 -60 200 120) to actual canvas size
    final scaleX = size.width / 200.0;
    final scaleY = size.height / 120.0;

    Offset svgToCanvas(double x, double y) =>
        Offset((x + 100) * scaleX, (y + 60) * scaleY);

    // Top-right segment: (22,-44) → (62,-4)
    canvas.drawLine(svgToCanvas(22, -44), svgToCanvas(62, -4), paint);
    // Bottom-left segment: (-22,44) → (-62,4)
    canvas.drawLine(svgToCanvas(-22, 44), svgToCanvas(-62, 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
