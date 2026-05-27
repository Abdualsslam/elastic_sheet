import 'package:flutter/material.dart';

class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    this.tapTargetKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key? tapTargetKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: tapTargetKey,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDBEAFE) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF374151),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
