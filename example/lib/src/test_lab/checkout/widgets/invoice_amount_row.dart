import 'package:flutter/material.dart';

class InvoiceAmountRow extends StatelessWidget {
  const InvoiceAmountRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueKey,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Key valueKey;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? const Color(0xFF111827) : const Color(0xFF4B5563);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          key: valueKey,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
