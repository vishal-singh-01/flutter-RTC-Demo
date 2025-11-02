import 'package:flutter/material.dart';


class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool busy;
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false});
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );
  }
}


class TextFieldX extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? type;
  final bool obscure;
  const TextFieldX({super.key, required this.controller, required this.hint, this.type, this.obscure = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}