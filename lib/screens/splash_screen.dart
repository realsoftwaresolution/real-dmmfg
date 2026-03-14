import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SplashScreenV7 extends StatefulWidget {
  const SplashScreenV7({Key? key}) : super(key: key);
  @override
  State<SplashScreenV7> createState() => _SplashScreenV7State();
}

class _SplashScreenV7State extends State<SplashScreenV7>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;      // Starfield twinkle
  late AnimationController _starsCtrl;   // Stars appear
  late AnimationController _linesCtrl;   // Connection lines draw
  late AnimationController _logoCtrl;    // Final logo coalesce
  late AnimationController _textCtrl;    // Text reveal
  late AnimationController _pulseCtrl;   // Logo pulse
  late AnimationController _exitCtrl;    // Exit fade

  late Animation<double> _starsReveal;
  late Animation<double> _linesProgress;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseSize;
  late Animation<double> _exitFade;

  final Random _rng = Random(12);
  late List<_Star> _stars;
  late List<_ConstellationLine> _lines;

  @override
  void initState() {
    super.initState();
    _buildStarfield();
    _initAnimations();
    _runSequence();
  }

  void _buildStarfield() {
    // Background stars
    _stars = List.generate(80, (i) => _Star(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 0.5 + _rng.nextDouble() * 2.0,
      brightness: 0.2 + _rng.nextDouble() * 0.8,
      twinkleSpeed: 0.3 + _rng.nextDouble() * 0.7,
      twinkleOffset: _rng.nextDouble(),
    ));

    // Constellation points forming "RS" shape
    // These are normalized coordinates (0-1) for key points
    _lines = const [
      // R shape
      _ConstellationLine(Offset(0.35, 0.38), Offset(0.35, 0.62), delay: 0.0),
      _ConstellationLine(Offset(0.35, 0.38), Offset(0.44, 0.38), delay: 0.05),
      _ConstellationLine(Offset(0.44, 0.38), Offset(0.46, 0.45), delay: 0.10),
      _ConstellationLine(Offset(0.46, 0.45), Offset(0.35, 0.49), delay: 0.15),
      _ConstellationLine(Offset(0.35, 0.49), Offset(0.44, 0.62), delay: 0.20),
      // S shape
      _ConstellationLine(Offset(0.56, 0.38), Offset(0.50, 0.40), delay: 0.25),
      _ConstellationLine(Offset(0.50, 0.40), Offset(0.50, 0.49), delay: 0.30),
      _ConstellationLine(Offset(0.50, 0.49), Offset(0.56, 0.50), delay: 0.35),
      _ConstellationLine(Offset(0.56, 0.50), Offset(0.56, 0.59), delay: 0.40),
      _ConstellationLine(Offset(0.56, 0.59), Offset(0.50, 0.62), delay: 0.45),
    ];
  }

  void _initAnimations() {
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();
    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _linesCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _starsReveal = CurvedAnimation(parent: _starsCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _linesProgress = CurvedAnimation(parent: _linesCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic)
        .drive(Tween(begin: const Offset(0, 0.5), end: Offset.zero));
    _pulseSize = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.95, end: 1.05));
    _exitFade = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 1.0, end: 0.0));
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _starsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _linesCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkSession();
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      _StarfieldRoute(
        page:  const LoginScreenV7(),
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _starsCtrl.dispose();
    _linesCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgCtrl, _starsCtrl, _linesCtrl,
          _logoCtrl, _textCtrl, _pulseCtrl, _exitCtrl
        ]),
        builder: (ctx, _) => Opacity(
          opacity: _exitFade.value,
          child: Stack(
            children: [
              // ── Deep space gradient ────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.0,
                    colors: [Color(0xFF0A0E2A), Color(0xFF03050F)],
                  ),
                ),
              ),

              // ── Nebula glow (soft colored fog) ────────────
              Center(
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF556EE6).withOpacity(0.08),
                        const Color(0xFF34C38F).withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Background stars + constellation ───────────
              CustomPaint(
                size: size,
                painter: _ConstellationPainter(
                  stars: _stars,
                  lines: _lines,
                  starsReveal: _starsReveal.value,
                  linesProgress: _linesProgress.value,
                  bgTwinkle: _bgCtrl.value,
                ),
              ),

              // ── Central logo card (coalesces from stars) ───
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Transform.scale(
                      scale: _pulseSize.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: _ConstellationLogo(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Text
                    SlideTransition(
                      position: _textSlide,
                      child: Opacity(
                        opacity: _textFade.value,
                        child: Column(
                          children: [
                            // Glowing name
                            Text(
                              'REAL SOFTWARE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 6,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF556EE6)
                                        .withOpacity(0.6),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF556EE6)
                                        .withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFF556EE6).withOpacity(0.08),
                              ),
                              child: const Text(
                                'ENTERPRISE  ·  ANALYTICS  ·  INTELLIGENCE',
                                style: TextStyle(
                                  color: Color(0xFF8B99FF),
                                  fontSize: 10,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            DiamondLoader(size: 64),

// NEW — 3 bouncing diamonds in row (like dots loader):
                            DiamondLoaderRow(count: 3, diamondSize: 22)                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Version watermark ──────────────────────────
              Positioned(
                bottom: 28,
                left: 0, right: 0,
                child: Opacity(
                  opacity: _textFade.value,
                  child: Center(
                    child: Text(
                      'v2.0.0  ·  © 2026 Real Software',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _StarfieldRoute extends PageRouteBuilder {
  final Widget page;
  _StarfieldRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 600),
    transitionsBuilder: (_, a, __, child) {
      final curved = CurvedAnimation(parent: a, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: Transform.scale(scale: 0.97 + 0.03 * curved.value, child: child),
      );
    },
  );
}

class DiamondLoaderRow extends StatefulWidget {
  final int count;
  final double diamondSize;
  final Color primaryColor;
  final Color accentColor;

  const DiamondLoaderRow({
    Key? key,
    this.count = 3,
    this.diamondSize = 22,
    this.primaryColor = const Color(0xFF556EE6),
    this.accentColor = const Color(0xFF34C38F),
  }) : super(key: key);

  @override
  State<DiamondLoaderRow> createState() => _DiamondLoaderRowState();
}

class _DiamondLoaderRowState extends State<DiamondLoaderRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.count, (i) {
          final phase = i / widget.count;
          final t = (_ctrl.value - phase + 1.0) % 1.0;
          final rise = sin(t * pi).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Transform.translate(
              offset: Offset(0, -10 * rise),
              child: Opacity(
                opacity: 0.35 + 0.65 * rise,
                child: SizedBox(
                  width: widget.diamondSize,
                  height: widget.diamondSize,
                  child: CustomPaint(
                    painter: _SmallDiamondPainter(
                      lightAngle: _ctrl.value * 2 * pi + i * 1.2,
                      primaryColor: widget.primaryColor,
                      accentColor: widget.accentColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Lightweight diamond for the row (no rotation, just light sweep)
class _SmallDiamondPainter extends CustomPainter {
  final double lightAngle;
  final Color primaryColor;
  final Color accentColor;

  _SmallDiamondPainter({
    required this.lightAngle,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;
    final lx = cos(lightAngle);
    final ly = sin(lightAngle);

    final top = Offset(cx, cy - r);
    final girL = Offset(cx - r * 0.78, cy - r * 0.08);
    final girR = Offset(cx + r * 0.78, cy - r * 0.08);
    final midL = Offset(cx - r * 0.16, cy - r * 0.08);
    final midR = Offset(cx + r * 0.16, cy - r * 0.08);
    final tabL = Offset(cx - r * 0.38, cy - r * 0.56);
    final tabR = Offset(cx + r * 0.38, cy - r * 0.56);
    final pavL = Offset(cx - r * 0.52, cy + r * 0.22);
    final pavR = Offset(cx + r * 0.52, cy + r * 0.22);
    final bot = Offset(cx, cy + r);

    Color fc(double b, double nx, double ny) {
      final dot = (lx * nx + ly * ny).clamp(-1.0, 1.0);
      final light = (b + dot * 0.35).clamp(0.0, 1.0);
      final t = ((dot + 1) / 2 * b).clamp(0.0, 1.0);
      final base = Color.lerp(primaryColor, accentColor, t * 0.6)!;
      return Color.lerp(base.withOpacity(0.55),
          Colors.white.withOpacity(0.92), light * 0.45)!
          .withOpacity(0.75 + light * 0.25);
    }

    void f(List<Offset> pts, Color c) {
      final p = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) p.lineTo(pts[i].dx, pts[i].dy);
      p.close();
      canvas.drawPath(p, Paint()..color = c);
    }

    void ln(Offset a, Offset b) => canvas.drawLine(a, b,
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = 0.5);

    // Glow
    canvas.drawCircle(Offset(cx, cy), r * 1.2,
        Paint()
          ..color = primaryColor.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Facets
    f([top, tabL, midL], fc(0.80, -0.5, -0.8));
    f([top, tabR, midR], fc(0.65, 0.5, -0.8));
    f([top, tabL, girL], fc(0.50, -0.8, -0.2));
    f([top, tabR, girR], fc(0.40, 0.8, -0.2));
    f([tabL, tabR, midR, midL], fc(0.95, 0.0, -1.0));
    f([girL, midL, pavL], fc(0.45, -0.9, 0.3));
    f([girR, midR, pavR], fc(0.35, 0.9, 0.3));
    f([midL, midR, pavR, pavL], fc(0.55, 0.0, 0.2));
    f([pavL, midL, bot], fc(0.30, -0.6, 0.8));
    f([pavR, midR, bot], fc(0.25, 0.6, 0.8));
    f([pavL, pavR, bot], fc(0.20, 0.0, 1.0));

    // Lines
    for (var pair in [
      [top, midL], [top, midR], [tabL, midL], [tabR, midR],
      [midL, midR], [midL, pavL], [midR, pavR],
      [midL, bot], [midR, bot], [pavL, bot], [pavR, bot],
    ]) ln(pair[0], pair[1]);

    // Outline
    final outline = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(tabL.dx, tabL.dy)
      ..lineTo(girL.dx, girL.dy)
      ..lineTo(pavL.dx, pavL.dy)
      ..lineTo(bot.dx, bot.dy)
      ..lineTo(pavR.dx, pavR.dy)
      ..lineTo(girR.dx, girR.dy)
      ..lineTo(tabR.dx, tabR.dy)
      ..close();
    canvas.drawPath(outline,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7);

    // Specular flash
    final fi = ((cos(lightAngle * 2) * 0.5 + 0.5)).clamp(0.0, 1.0);
    if (fi > 0.3) {
      canvas.drawCircle(Offset(cx - r * 0.1, cy - r * 0.3), r * 0.1,
          Paint()
            ..color = Colors.white.withOpacity(fi * 0.9)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _SmallDiamondPainter old) =>
      old.lightAngle != lightAngle;
}
class DiamondLoader extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const DiamondLoader({
    Key? key,
    this.size = 64,
    this.primaryColor = const Color(0xFF556EE6),
    this.accentColor = const Color(0xFF34C38F),
  }) : super(key: key);

  @override
  State<DiamondLoader> createState() => _DiamondLoaderState();
}

class _DiamondLoaderState extends State<DiamondLoader>
    with TickerProviderStateMixin {
  // Rotation — slow majestic spin
  late AnimationController _rotateCtrl;
  late Animation<double> _rotate;

  // Light sweep — refraction shimmer
  late AnimationController _lightCtrl;
  late Animation<double> _lightAngle;

  // Scale pulse — breathing gem
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // Float — gentle up/down
  late AnimationController _floatCtrl;
  late Animation<double> _floatY;

  @override
  void initState() {
    super.initState();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _lightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _rotate = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateCtrl, curve: Curves.linear),
    );

    _lightAngle = Tween<double>(begin: -pi, end: pi).animate(
      CurvedAnimation(parent: _lightCtrl, curve: Curves.easeInOut),
    );

    _pulse = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatY = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _lightCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_rotateCtrl, _lightCtrl, _pulseCtrl, _floatCtrl]),
      builder: (ctx, _) {
        return Transform.translate(
          offset: Offset(0, _floatY.value),
          child: Transform.scale(
            scale: _pulse.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _DiamondPainter(
                  rotate: _rotate.value,
                  lightAngle: _lightAngle.value,
                  primaryColor: widget.primaryColor,
                  accentColor: widget.accentColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── The actual diamond painter ────────────────────────────────────
class _DiamondPainter extends CustomPainter {
  final double rotate;
  final double lightAngle;
  final Color primaryColor;
  final Color accentColor;

  _DiamondPainter({
    required this.rotate,
    required this.lightAngle,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotate);
    canvas.translate(-cx, -cy);

    // ── Outer glow (halo around gem) ────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.35,
      Paint()
        ..color = primaryColor.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.1,
      Paint()
        ..color = primaryColor.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── Diamond outline points ──────────────────────────────
    // Classic brilliant cut shape: wide girdle, pointed bottom
    final top = Offset(cx, cy - r);                        // Crown tip
    final girLeft = Offset(cx - r * 0.78, cy - r * 0.08); // Girdle left
    final girRight = Offset(cx + r * 0.78, cy - r * 0.08);// Girdle right
    final pawLeft = Offset(cx - r * 0.52, cy + r * 0.22); // Pavilion left
    final pawRight = Offset(cx + r * 0.52, cy + r * 0.22);// Pavilion right
    final bottom = Offset(cx, cy + r);                     // Culet (bottom tip)
    final midLeft = Offset(cx - r * 0.16, cy - r * 0.08); // Inner mid-left
    final midRight = Offset(cx + r * 0.16, cy - r * 0.08);// Inner mid-right
    final tableLeft = Offset(cx - r * 0.38, cy - r * 0.56); // Table edge left
    final tableRight = Offset(cx + r * 0.38, cy - r * 0.56);// Table edge right

    // ── FACETS — each with own color/brightness ─────────────
    // Light source moves with lightAngle
    final lx = cos(lightAngle);
    final ly = sin(lightAngle);

    _drawFacet(canvas, [top, tableLeft, midLeft],
        _facetColor(0.80, lx, ly, -0.5, -0.8));
    _drawFacet(canvas, [top, tableRight, midRight],
        _facetColor(0.65, lx, ly, 0.5, -0.8));
    _drawFacet(canvas, [top, tableLeft, girLeft],
        _facetColor(0.50, lx, ly, -0.8, -0.2));
    _drawFacet(canvas, [top, tableRight, girRight],
        _facetColor(0.40, lx, ly, 0.8, -0.2));
    _drawFacet(canvas, [tableLeft, tableRight, midRight, midLeft],
        _facetColor(0.95, lx, ly, 0.0, -1.0)); // Table (top face — brightest)
    _drawFacet(canvas, [girLeft, midLeft, pawLeft],
        _facetColor(0.45, lx, ly, -0.9, 0.3));
    _drawFacet(canvas, [girRight, midRight, pawRight],
        _facetColor(0.35, lx, ly, 0.9, 0.3));
    _drawFacet(canvas, [midLeft, midRight, pawRight, pawLeft],
        _facetColor(0.55, lx, ly, 0.0, 0.2));
    _drawFacet(canvas, [pawLeft, midLeft, bottom],
        _facetColor(0.30, lx, ly, -0.6, 0.8));
    _drawFacet(canvas, [pawRight, midRight, bottom],
        _facetColor(0.25, lx, ly, 0.6, 0.8));
    _drawFacet(canvas, [pawLeft, pawRight, bottom],
        _facetColor(0.20, lx, ly, 0.0, 1.0));
    _drawFacet(canvas, [girLeft, pawLeft, bottom, cx > 0 ? bottom : bottom],
        _facetColor(0.15, lx, ly, -0.4, 0.9));

    // ── Girdle outline ──────────────────────────────────────
    final girdlePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(tableLeft.dx, tableLeft.dy)
      ..lineTo(girLeft.dx, girLeft.dy)
      ..lineTo(pawLeft.dx, pawLeft.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(pawRight.dx, pawRight.dy)
      ..lineTo(girRight.dx, girRight.dy)
      ..lineTo(tableRight.dx, tableRight.dy)
      ..close();

    canvas.drawPath(
      girdlePath,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // ── Inner facet lines ───────────────────────────────────
    _drawLine(canvas, top, midLeft);
    _drawLine(canvas, top, midRight);
    _drawLine(canvas, tableLeft, midLeft);
    _drawLine(canvas, tableRight, midRight);
    _drawLine(canvas, midLeft, midRight);
    _drawLine(canvas, midLeft, pawLeft);
    _drawLine(canvas, midRight, pawRight);
    _drawLine(canvas, midLeft, bottom);
    _drawLine(canvas, midRight, bottom);
    _drawLine(canvas, pawLeft, bottom);
    _drawLine(canvas, pawRight, bottom);
    _drawLine(canvas, girLeft, midLeft);
    _drawLine(canvas, girRight, midRight);

    // ── Light specular flare ────────────────────────────────
    final flareX = cx + r * 0.2 * cos(lightAngle - pi / 4);
    final flareY = cy - r * 0.3 + r * 0.15 * sin(lightAngle);
    final flareIntensity = (cos(lightAngle * 2) * 0.5 + 0.5).clamp(0.0, 1.0);

    canvas.drawCircle(
      Offset(flareX, flareY),
      r * 0.08,
      Paint()
        ..color = Colors.white.withOpacity(0.85 * flareIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(flareX, flareY),
      r * 0.03,
      Paint()..color = Colors.white.withOpacity(flareIntensity),
    );

    // ── Rainbow refraction streaks ──────────────────────────
    if (flareIntensity > 0.4) {
      final ri = (flareIntensity - 0.4) / 0.6;
      final refractionColors = [
        Colors.red.withOpacity(0.25 * ri),
        Colors.orange.withOpacity(0.2 * ri),
        Colors.yellow.withOpacity(0.25 * ri),
        Colors.cyan.withOpacity(0.2 * ri),
        Colors.blue.withOpacity(0.2 * ri),
      ];
      for (int i = 0; i < refractionColors.length; i++) {
        final angle = lightAngle + pi / 6 + (i * 0.18);
        final streakLen = r * 0.4;
        canvas.drawLine(
          Offset(flareX, flareY),
          Offset(
            flareX + streakLen * cos(angle),
            flareY + streakLen * sin(angle),
          ),
          Paint()
            ..color = refractionColors[i]
            ..strokeWidth = 1.2
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    canvas.restore();
  }

  // Compute facet color based on normal vs light direction
  Color _facetColor(double baseBrightness, double lx, double ly,
      double nx, double ny) {
    final dot = (lx * nx + ly * ny).clamp(-1.0, 1.0);
    final light = (baseBrightness + dot * 0.35).clamp(0.0, 1.0);

    // Blend between primary and accent based on facet + light
    final t = ((dot + 1) / 2 * baseBrightness).clamp(0.0, 1.0);
    final base = Color.lerp(primaryColor, accentColor, t * 0.6)!;

    return Color.lerp(
      base.withOpacity(0.55),
      Colors.white.withOpacity(0.92),
      light * 0.45,
    )!.withOpacity(0.75 + light * 0.25);
  }

  void _drawFacet(Canvas canvas, List<Offset> pts, Color color) {
    if (pts.length < 3) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawLine(Canvas canvas, Offset a, Offset b) {
    canvas.drawLine(
      a, b,
      Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 0.6,
    );
  }

  @override
  bool shouldRepaint(covariant _DiamondPainter old) =>
      old.rotate != rotate || old.lightAngle != lightAngle;
}
class _Star {
  final double x, y, size, brightness, twinkleSpeed, twinkleOffset;
  const _Star({
    required this.x, required this.y, required this.size,
    required this.brightness, required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class _ConstellationLine {
  final Offset a, b;
  final double delay;
  const _ConstellationLine(this.a, this.b, {required this.delay});
}

class _ConstellationPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_ConstellationLine> lines;
  final double starsReveal, linesProgress, bgTwinkle;

  _ConstellationPainter({
    required this.stars,
    required this.lines,
    required this.starsReveal,
    required this.linesProgress,
    required this.bgTwinkle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background stars
    for (final star in stars) {
      if (starsReveal < star.twinkleOffset * 0.8) continue;
      final t = sin(bgTwinkle * 2 * pi * star.twinkleSpeed + star.twinkleOffset * 2 * pi);
      final brightness = star.brightness * (0.6 + 0.4 * t);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        Paint()
          ..color = Colors.white.withOpacity(brightness * starsReveal)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5),
      );
    }

    // Constellation lines — draw progressively
    for (final line in lines) {
      final t = ((linesProgress - line.delay) / (1 - line.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final a = Offset(line.a.dx * size.width, line.a.dy * size.height);
      final b = Offset(line.b.dx * size.width, line.b.dy * size.height);
      final end = Offset.lerp(a, b, t)!;

      // Glowing line
      canvas.drawLine(a, end,
          Paint()
            ..color = const Color(0xFF556EE6).withOpacity(0.5 * t)
            ..strokeWidth = 1.0
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawLine(a, end,
          Paint()
            ..color = Colors.white.withOpacity(0.3 * t)
            ..strokeWidth = 0.5);

      // Star nodes at endpoints
      for (final pt in [a, if (t > 0.95) b]) {
        canvas.drawCircle(pt, 3,
            Paint()
              ..color = Colors.white.withOpacity(0.9)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        canvas.drawCircle(pt, 1.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.starsReveal != starsReveal ||
          old.linesProgress != linesProgress ||
          old.bgTwinkle != bgTwinkle;
}

class _ConstellationLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow rings
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF556EE6).withOpacity(0.12), width: 1),
          ),
        ),
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF556EE6).withOpacity(0.2), width: 1),
          ),
        ),
        // Core
        Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E2557), Color(0xFF0A0E2A)],
              ),
              border: Border.all(
                  color: const Color(0xFF556EE6).withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF556EE6).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png',color: Colors.white,)
          // Center(
          //   child: ShaderMask(
          //     shaderCallback: (b) => const LinearGradient(
          //       colors: [Color(0xFF8B99FF), Colors.white],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ).createShader(b),
          //     child: const Text(
          //       'RS',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 28,
          //         fontWeight: FontWeight.w900,
          //         letterSpacing: -1,
          //       ),
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }
}
