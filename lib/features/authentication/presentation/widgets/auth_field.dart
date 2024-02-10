import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isObscuredText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const AuthField({
    Key? key,
    required this.label,
    required this.controller,
    required this.isObscuredText,
    required this.keyboardType,
    required this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscuredText,
        keyboardType: keyboardType,
        autocorrect: false,
        enableSuggestions: false,
        validator: validator,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
