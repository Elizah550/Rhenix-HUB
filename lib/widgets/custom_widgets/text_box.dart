import 'package:flutter/material.dart';
//
// class BorderedTextField extends StatefulWidget {
//   final String labelText;
//   final double borderRadius;
//   final double padding;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//
//   const BorderedTextField({
//     Key? key,
//     required this.labelText,
//     required this.borderRadius,
//     required this.padding,
//     required this.keyboardType,
//     this.controller,
//     this.validator,
//   }) : super(key: key);
//
//   @override
//   State<BorderedTextField> createState() => _BorderedTextFieldState();
// }
//
// class _BorderedTextFieldState extends State<BorderedTextField> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(widget.padding),
//       child: TextFormField(
//         keyboardType: widget.keyboardType,
//         controller: widget.controller,
//         validator: widget.validator,
//         decoration: InputDecoration(
//           labelText: widget.labelText,
//           fillColor: Colors.white,
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor),
//             borderRadius: BorderRadius.circular(widget.borderRadius),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
//             borderRadius: BorderRadius.circular(widget.borderRadius),
//           ),
//         ),
//       ),
//     );
//   }
// }

class BorderedTextField extends StatefulWidget {
  final String labelText;
  final double borderRadius;
  final double padding;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const BorderedTextField({
    Key? key,
    required this.labelText,
    required this.borderRadius,
    required this.padding,
    required this.keyboardType,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  State<BorderedTextField> createState() => _BorderedTextFieldState();
}

class _BorderedTextFieldState extends State<BorderedTextField> {
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        onChanged: (value) {
          _onTextChanged();
        },
        autovalidateMode: _autoValidateMode,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}