import 'package:diam_mfg/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../providers/auth_provider.dart';
import '../providers/company_provider.dart';

import 'company_dialogue.dart';

class LoginScreenV7 extends StatefulWidget {
  const LoginScreenV7({Key? key}) : super(key: key);

  @override
  State<LoginScreenV7> createState() => _LoginScreenV7State();
}

class _LoginScreenV7State extends State<LoginScreenV7> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _signInFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _emailFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _signInFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.login(
        username: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (ok && mounted) {
        final companyProvider = context.read<CompanyProvider>();
        final prov = context.read<MenuProvider>();
        await prov.loadMenus();
        if (!mounted) return;
        await companyProvider.loadCompanies();
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        await showCompanySelectionDialog(context);
      } else {
        if (mounted) {
          _emailFocus.requestFocus();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _s(int i, Widget child) {
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      body: Stack(
        children: [
          // ── Premium deep dark gradient background ─────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF03050F),
                  Color(0xFF0C0F24),
                  Color(0xFF060814),
                ],
              ),
            ),
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
                    const Color(0xFF556EE6).withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Layout ──────────────────────────────────────
          isMobile ? _buildMobileLayout() : _buildDesktopLayout(size),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SpaceLogo(),
                    const SizedBox(height: 32),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF8B99FF)],
                      ).createShader(b),
                      child: const Text(
                        'DIAMOND MFG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Diamond Manufacturing ERP',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.07),

            // Right: static glass form
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Container(
                  width: size.width < 1100 ? 400 : 450,
                  constraints: BoxConstraints(maxHeight: size.height - 80),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1330).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF556EE6).withOpacity(0.2),
                      width: 1,
                    ),
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
                          _buildFormHeader(),
                          const SizedBox(height: 30),
                          _SpaceField(
                            controller: _emailCtrl,
                            label: 'USER NAME',
                            hint: 'Enter your username',
                            icon: Icons.alternate_email_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              _passFocus.requestFocus();
                            },
                          ),
                          const SizedBox(height: 18),
                          _SpaceField(
                            controller: _passCtrl,
                            label: 'PASSWORD',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
                            focusNode: _passFocus,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            suffix: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscure = !_obscure),
                              child: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: Colors.white30,
                              ),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 26),
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => Column(
                              children: [
                                _SpaceButton(
                                  focusNode: _signInFocus,
                                  isLoading: _isLoading || auth.isLoading,
                                  onPressed:
                                      (_isLoading || auth.isLoading)
                                          ? null
                                          : _login,
                                ),
                                if (auth.errorMessage != null) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF46A6A,
                                      ).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFF46A6A,
                                        ).withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Color(0xFFF46A6A),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            auth.errorMessage!,
                                            style: const TextStyle(
                                              color: Color(0xFFF46A6A),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              '© 2026 Real Software / Diamond Mfg',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.2),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
            _SpaceLogo(),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Colors.white, Color(0xFF8B99FF)],
              ).createShader(b),
              child: const Text(
                'DIAMOND MFG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1330).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF556EE6).withOpacity(0.2),
                ),
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
                      focusNode: _passFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: Colors.white30,
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => _SpaceButton(
                        focusNode: _signInFocus,
                        isLoading: _isLoading || auth.isLoading,
                        onPressed:
                            (_isLoading || auth.isLoading) ? null : _login,
                      ),
                    ),
                    const SizedBox(height: 16),
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
        const Text(
          'Welcome back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to access your dashboard',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        ),
      ],
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────

class _SpaceLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF556EE6).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E2557), Color(0xFF0A0E2A)],
            ),
            border: Border.all(
              color: const Color(0xFF556EE6).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF556EE6).withOpacity(0.35),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Image.asset('assets/images/logo.png', color: Colors.white),
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
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
      ),
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
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const _SpaceField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: const Color(0xFF556EE6),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
            suffixIcon: suffix != null
                ? Padding(padding: const EdgeInsets.all(12), child: suffix)
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF556EE6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF46A6A)),
            ),
            errorStyle: const TextStyle(color: Color(0xFFF46A6A), fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpaceButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final FocusNode? focusNode;

  const _SpaceButton({this.onPressed, this.isLoading = false, this.focusNode});

  @override
  State<_SpaceButton> createState() => _SpaceButtonState();
}

class _SpaceButtonState extends State<_SpaceButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hovered
                    ? [const Color(0xFF6B7EFF), const Color(0xFF45D3A0)]
                    : [const Color(0xFF556EE6), const Color(0xFF4055C8)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Sign In →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
