import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).dividerColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        hintStyle: Theme.of(context).textTheme.bodyMedium,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(
            width: Dimensions.width5 / Dimensions.width50,
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(
            width: Dimensions.width5 / Dimensions.width10,
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(
            width: Dimensions.width5 / Dimensions.width10,
            color: Theme.of(context).dividerColor,

          ),
        ),
      ),
    );
  }
}