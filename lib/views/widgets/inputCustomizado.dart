import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatelessWidget {

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final int? maxLines;
  final TextInputType type;
  final List<TextInputFormatter>? inputFotmatters;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;

  InputCustomizado({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.type = TextInputType.text,
    this.inputFotmatters,
    this.validator,
    this.onSaved,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: this.obscure,
      autofocus: this.autofocus,
      keyboardType: this.type,
      inputFormatters: this.inputFotmatters,
      validator: this.validator,
      maxLines: this.maxLines,
      onSaved: this.onSaved,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(32, 16, 31, 16),
          hintText: this.hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6)
          )
      ),
    );
  }
}
