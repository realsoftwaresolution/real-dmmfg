import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/app_router.dart';

class LoginScreenV7 extends StatefulWidget {
  const LoginScreenV7({Key? key}) : super(key: key);
  @override
  State<LoginScreenV7> createState() => _LoginScreenV7State();
}

class _LoginScreenV7State extends State<LoginScreenV7>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'Real');
  final _passCtrl = TextEditingController(text: '123');
  bool _obscure = true;
  bool _remember = true;

  late AnimationController _bgCtrl;      // starfield
  late AnimationController _floatCtrl;   // card float
  late AnimationController _entryCtrl;   // stagger entry

  late Animation<double> _floatY;
  late List<Animation<double>> _stagger;

  final _rand = Random(99);
  late List<_LoginStar> _stars;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(60, (_) => _LoginStar(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      size: 0.5 + _rand.nextDouble() * 1.5,
      brightness: 0.15 + _rand.nextDouble() * 0.7,
    ));

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))..repeat();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _floatY = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _stagger = List.generate(7, (i) {
      final s = (i * 0.1).clamp(0.0, 0.8);
      final e = (s + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, e, curve: Curves.easeOutCubic),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgCtrl.dispose();
    _floatCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
        username: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (ok && mounted) {
      final menuProvider=context.read<MenuProvider>();
      // Navigator.pushReplacementNamed(context, '/dashboard');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardLayout(menu: menuProvider.menus, router: AppRouter.router, sideHeader: 'Real-Dmmfg',)));
    }
  }

  Widget _s(int i, Widget child) {
    return AnimatedBuilder(
      animation: _stagger[i],
      builder: (_, __) => Opacity(
        opacity: _stagger[i].value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _stagger[i].value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _floatCtrl, _entryCtrl]),
        builder: (ctx, _) => Stack(
          children: [
            // ── Starfield background ─────────────────────────
            CustomPaint(
              size: size,
              painter: _SpaceBackgroundPainter(_stars, _bgCtrl.value),
            ),

            // ── Nebula center glow ───────────────────────────
            Center(
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF556EE6).withOpacity(0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Layout ──────────────────────────────────────
            isMobile
                ? _buildMobileLayout()
                : _buildDesktopLayout(size),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    final padding = ResponsiveValue<double>(
      mobile: 20,
      tablet: 32,
      desktop: 60,
    ).getValue(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),

        child: Row(

          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding:  EdgeInsets.symmetric(  horizontal: size.width * 0.04,),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _s(0, _SpaceLogo()),
                    const SizedBox(height: 32),
                    _s(1, ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF8B99FF)],
                      ).createShader(b),
                      child: const Text('REAL SOFTWARE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -1,
                          )),
                    )),
                    const SizedBox(height: 16),
                    _s(2, Text(
                      'Enterprise Dashboard Intelligence',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    )),
                    const SizedBox(height: 48),

                    _s(3, Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SpacePill('📊 Analytics'),
                        _SpacePill('👥 Teams'),
                        _SpacePill('🔒 Secure'),
                        _SpacePill('⚡ Real-time'),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.07),


            // Right: floating glass form
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Transform.translate(
                  offset: Offset(0, _floatY.value),
                  child: Container(
                    width: size.width < 1100 ? 400 : 450,
                    constraints: BoxConstraints(maxHeight: size.height - 80),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1330).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFF556EE6).withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF556EE6).withOpacity(0.1),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _s(0, _buildFormHeader()),
                            const SizedBox(height: 30),
                            _s(1, _SpaceField(
                              controller: _emailCtrl,
                              label: 'EMAIL',
                              hint: 'you@company.com',
                              icon: Icons.alternate_email_rounded,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            )),
                            const SizedBox(height: 18),
                            _s(2, _SpaceField(
                              controller: _passCtrl,
                              label: 'PASSWORD',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscure,
                              suffix: GestureDetector(
                                onTap: () => setState(() => _obscure = !_obscure),
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18, color: Colors.white30,
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            )),
                            const SizedBox(height: 14),
                            _s(3, Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _remember = !_remember),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 18, height: 18,
                                        decoration: BoxDecoration(
                                          color: _remember
                                              ? const Color(0xFF556EE6)
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: _remember
                                                  ? const Color(0xFF556EE6)
                                                  : Colors.white24),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: _remember
                                            ? const Icon(Icons.check,
                                            size: 12, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Remember me',
                                          style: TextStyle(
                                              color: Colors.white.withOpacity(0.45),
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(horizontal: 4)),
                                  child: const Text('Forgot?',
                                      style: TextStyle(
                                          color: Color(0xFF8B99FF), fontSize: 13)),
                                ),
                              ],
                            )),
                            const SizedBox(height: 26),
                            _s(4, Consumer<AuthProvider>(
                              builder: (_, auth, __) => Column(
                                children: [
                                  _SpaceButton(
                                    isLoading: auth.isLoading,
                                    onPressed: auth.isLoading ? null : _login,
                                  ),
                                  if (auth.errorMessage != null) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF46A6A).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFF46A6A).withOpacity(0.25)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.warning_amber_rounded,
                                              color: Color(0xFFF46A6A), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(auth.errorMessage!,
                                                style: const TextStyle(
                                                    color: Color(0xFFF46A6A),
                                                    fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                            // const SizedBox(height: 24),
                            // _s(5, _buildSocialRow()),
                            const SizedBox(height: 20),
                            _s(5, Center(
                              child: Text('© 2026 Real Software',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.2),
                                      fontSize: 11)),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.07),

          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
        child: Column(
          children: [
            _s(0, _SpaceLogo()),
            const SizedBox(height: 24),
            _s(1, ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Colors.white, Color(0xFF8B99FF)],
              ).createShader(b),
              child: const Text('REAL SOFTWARE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
            )),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1330).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF556EE6).withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormHeader(),
                    const SizedBox(height: 24),
                    _SpaceField(
                      controller: _emailCtrl,
                      label: 'EMAIL',
                      hint: 'you@company.com',
                      icon: Icons.alternate_email_rounded,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _SpaceField(
                      controller: _passCtrl,
                      label: 'PASSWORD',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.white30),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => _SpaceButton(
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _login,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // _buildSocialRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Sign in to access your dashboard',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 13)),
      ],
    );
  }


}
class _LoginStar {
  final double x, y, size, brightness;
  _LoginStar({
    required this.x, required this.y,
    required this.size, required this.brightness,
  });
}

class _SpaceBackgroundPainter extends CustomPainter {
  final List<_LoginStar> stars;
  final double t;
  _SpaceBackgroundPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF03050F),
    );
    for (final star in stars) {
      final twinkle = 0.5 + 0.5 * sin(t * 2 * pi * (0.5 + star.brightness));
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        Paint()
          ..color = Colors.white.withOpacity(star.brightness * twinkle)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceBackgroundPainter old) => old.t != t;
}
// ── Shared sub-widgets ────────────────────────────────────────────────

class _SpaceLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF556EE6).withOpacity(0.2), width: 1),
          ),
        ),
        Container(
            width: 68, height: 68,
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
                  color: const Color(0xFF556EE6).withOpacity(0.35),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png',color: Colors.white,)

          // child: Center(
          //   child: ShaderMask(
          //     shaderCallback: (b) => const LinearGradient(
          //       colors: [Color(0xFF8B99FF), Colors.white],
          //     ).createShader(b),
          //     child: const Text('RS',
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 24,
          //             fontWeight: FontWeight.w900,
          //             letterSpacing: -1)),
          //   ),
          // ),
        ),
      ],
    );
  }
}

class _SpacePill extends StatelessWidget {
  final String label;
  const _SpacePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.7), fontSize: 13)),
    );
  }
}

class _SpaceField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _SpaceField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: const Color(0xFF556EE6),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 14),
            prefixIcon: Icon(icon,
                color: Colors.white.withOpacity(0.3), size: 20),
            suffixIcon: suffix != null
                ? Padding(padding: const EdgeInsets.all(12), child: suffix)
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF556EE6), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFF46A6A)),
            ),
            errorStyle: const TextStyle(
                color: Color(0xFFF46A6A), fontSize: 12),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _SpaceButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  const _SpaceButton({this.onPressed, this.isLoading = false});

  @override
  State<_SpaceButton> createState() => _SpaceButtonState();
}

class _SpaceButtonState extends State<_SpaceButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [const Color(0xFF6B7EFF), const Color(0xFF45D3A0)]
                  : [const Color(0xFF556EE6), const Color(0xFF4055C8)],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF556EE6)
                    .withOpacity(_hovered ? 0.5 : 0.25),
                blurRadius: _hovered ? 24 : 12,
                spreadRadius: _hovered ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            )
                : const Text('Sign In →',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3)),
          ),
        ),
      ),
    );
  }
}