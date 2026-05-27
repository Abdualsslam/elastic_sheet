import 'package:flutter/material.dart';

class CheckoutField extends StatelessWidget {
  const CheckoutField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
