import 'package:flutter/material.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class ErpResultDialog {
  /// ── SUCCESS ────────────────────────────────────────────────────────────────
  static Future<void> showSuccess({
    required BuildContext context,
    required ErpTheme theme,
    required String message,
    String title = 'Success',
    Duration duration = const Duration(seconds: 2),
  }) async {
    await _show(
      context: context,
      theme: theme,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green.shade600,
      duration: duration,
    );
  }

  /// ── ERROR ──────────────────────────────────────────────────────────────────
  static Future<void> showError({
    required BuildContext context,
    required ErpTheme theme,
    required String message,
    String title = 'Error',
  }) async {
    await _show(
      context: context,
      theme: theme,
      title: title,
      message: message,
      icon: Icons.error_rounded,
      iconColor: Colors.red.shade600,
    );
  }

  /// ── DELETE SUCCESS ─────────────────────────────────────────────────────────
  static Future<void> showDeleted({
    required BuildContext context,
    required ErpTheme theme,
    required String itemName,
  }) async {
    await _show(
      context: context,
      theme: theme,
      title: 'Deleted',
      message: '"$itemName" deleted successfully.',
      icon: Icons.delete_rounded,
      iconColor: Colors.red.shade600,
      duration: const Duration(seconds: 2),
    );
  }

  /// ── INTERNAL ───────────────────────────────────────────────────────────────
  static Future<void> _show({
    required BuildContext context,
    required ErpTheme theme,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    Duration? duration,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ErpResultDialogWidget(
        theme: theme,
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        duration: duration,
      ),
    );
  }
}

class _ErpResultDialogWidget extends StatefulWidget {
  final ErpTheme theme;
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Duration? duration;

  const _ErpResultDialogWidget({
    required this.theme,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.duration,
  });

  @override
  State<_ErpResultDialogWidget> createState() => _ErpResultDialogWidgetState();
}

class _ErpResultDialogWidgetState extends State<_ErpResultDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();

    // Auto-close after duration if set
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: widget.theme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Gradient header ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.theme.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),

                // ── Content ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.theme.text,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.theme.textLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Divider ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: widget.theme.border),
                ),

                // ── OK button ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor:
                        widget.theme.primary.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: widget.theme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}