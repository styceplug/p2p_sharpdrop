import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;


  const PasswordTextField({
    super.key,
    this.controller,

  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    double borderWidth = (Dimensions.width5 / Dimensions.width5);
    if (borderWidth.isNegative || borderWidth == 0.0) {
      borderWidth = 1.0; // Fallback to 1.0 if the calculation is invalid
    }
    return TextField(

      controller: widget.controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        prefixIcon:  Icon(Icons.lock_open_outlined,color: Theme.of(context).dividerColor),
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          child: Icon(showPassword ? Icons.visibility : Icons.visibility_off,color: Theme.of(context).dividerColor),
        ),
        hintText: 'Password',
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,

          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,

          ),
        ),
      ),
    );
  }
}