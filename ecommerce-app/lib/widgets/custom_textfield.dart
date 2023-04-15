import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final IconData icon;
  final Color labelColor;

  const CustomTextField(
      {Key key,
      this.hintText,
      this.labelText,
      this.controller,
      this.icon,
      this.labelColor})
      : super(key: key);
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: TextStyle(
        color: Colors.black,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        suffixIcon: Icon(
          widget.icon,
          size: 15,
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.labelColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Colors.black26,
          fontSize: 13,
        ),
        hintText: widget.hintText,
      ),
    );
  }
}
