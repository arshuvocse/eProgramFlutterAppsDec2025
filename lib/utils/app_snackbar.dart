import 'package:flutter/material.dart';

enum SnackTone { success, error, warning }

/// Centralized snackbar styling for consistent look across the app.
class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackTone tone = SnackTone.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = _palette(tone);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.background,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        content: Row(
          children: [
            Icon(colors.icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _SnackColors _palette(SnackTone tone) {
    switch (tone) {
      case SnackTone.error:
        return _SnackColors(Colors.red.shade700, Icons.error_outline);
      case SnackTone.warning:
        return _SnackColors(Colors.orange.shade700, Icons.warning_amber_outlined);
      case SnackTone.success:
      default:
        return _SnackColors(Colors.green.shade700, Icons.check_circle_outline);
    }
  }
}

class _SnackColors {
  final Color background;
  final IconData icon;
  const _SnackColors(this.background, this.icon);
}
