import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

// ── Delete Confirm Dialog ─────────────────────────────────────────────────────
class ErpDeleteDialog {
  static Future<bool?> show({
    required BuildContext context,
    required ErpTheme theme,
    required String title,
    required String itemName,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black38,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 12,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──────────────────────────────────────────────────
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.shade100, width: 2),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade500, size: 26),
                ),
                const SizedBox(height: 14),

                // ── Title ─────────────────────────────────────────────────
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Message ───────────────────────────────────────────────
                Text(
                  customMessage ?? 'Are you sure you want to delete\n"$itemName"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(height: 1),
                const SizedBox(height: 14),

                // ── Buttons ───────────────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.textLight,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 14),
                          SizedBox(width: 6),
                          Text('Delete',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── SnackBar Helper ───────────────────────────────────────────────────────────
class ErpSnackBar {
  static void _show(
      BuildContext context, {
        required String message,
        required Color color,
        required IconData icon,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void success(BuildContext context,
      {required ErpTheme theme, required String message}) {
    _show(context,
        message: message,
        color: theme.primary,
        icon: Icons.check_circle_outline_rounded);
  }

  static void deleted(BuildContext context,
      {required ErpTheme theme, required String message}) {
    _show(context,
        message: message,
        color: Colors.red.shade600,
        icon: Icons.delete_outline_rounded);
  }

  static void error(BuildContext context, {required String message}) {
    _show(context,
        message: message,
        color: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded);
  }
}