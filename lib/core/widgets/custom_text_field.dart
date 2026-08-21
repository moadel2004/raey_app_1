import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          textAlign: textAlign,
          style: style,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
