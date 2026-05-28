import 'package:flutter/material.dart';

class PlaygroundControlCard extends StatelessWidget {
  const PlaygroundControlCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.padding = const EdgeInsets.all(18),
    this.scrollableChild = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollableChild;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x08000000),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: scrollableChild ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (scrollableChild)
            Expanded(child: SingleChildScrollView(primary: false, child: child))
          else
            child,
        ],
      ),
    );
  }
}
