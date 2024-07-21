import 'package:flutter/material.dart';

class BorderedTextFieldLogin extends StatefulWidget {
  final String labelText;
  final double borderRadius;
  final double padding;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const BorderedTextFieldLogin({
    Key? key,
    required this.labelText,
    required this.borderRadius,
    required this.padding,
    required this.keyboardType,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  State<BorderedTextFieldLogin> createState() => _BorderedTextFieldStateLogin();
}

class _BorderedTextFieldStateLogin extends State<BorderedTextFieldLogin> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}