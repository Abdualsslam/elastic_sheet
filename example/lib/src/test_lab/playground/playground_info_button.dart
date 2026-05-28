import 'package:flutter/material.dart';

import 'playground_models.dart';

class PlaygroundInfoButton extends StatelessWidget {
  const PlaygroundInfoButton({
    super.key,
    required this.title,
    required this.description,
    this.buttonKey,
  });

  final String title;
  final String description;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'What is $title?',
      child: InkResponse(
        key: buttonKey,
        radius: 16,
        onTap: () => _showInfoDialog(context, isDark),
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context, bool isDark) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF111827),
              ),
            ),
            content: Text(
              description,
              style: TextStyle(
                height: 1.5,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF4B5563),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  playgroundCloseDialogText,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF818CF8)
                        : const Color(0xFF4F46E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
