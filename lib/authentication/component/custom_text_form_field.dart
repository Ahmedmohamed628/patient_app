import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class CustomTextFormField extends StatefulWidget {
  String label;
  TextInputType keyboardType;
  TextEditingController controller;
  String? Function(String?) validator;
  bool isPassword;
  Widget? suffixIcon;
  Widget? prefixIcon;

  CustomTextFormField(
      {required this.label,
      this.keyboardType = TextInputType.text,
      required this.controller,
      required this.validator,
      this.isPassword = false,
      this.suffixIcon,
      this.prefixIcon});

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isObscure = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          // errorStyle: TextStyle(color: Colors.black54),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon:
                      Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                  color: MyTheme.redColor)
              : null,
          prefixIcon: widget.prefixIcon,
          labelStyle: TextStyle(color: MyTheme.redColor),
          label: Text(widget.label),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(width: 3, color: MyTheme.redColor)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(width: 3, color: MyTheme.redColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(width: 3, color: MyTheme.redColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(width: 3, color: MyTheme.redColor)),
        ),
        keyboardType: widget.keyboardType,
        // de 3mltha 3shan a8yr no3 el keyboard 3la 7sb ana hktb fe el email/ password/ name.. lw password yb2a keyboard arkam w hakza
        controller: widget.controller,
        // 3shan a5od el data elly ktbha el user
        validator: widget.validator,
        obscureText: isObscure,
      ),
    );
  }
}
