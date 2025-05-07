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