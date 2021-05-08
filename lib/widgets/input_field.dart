import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String text;
  final TextInputType inputType;
  final TextEditingController controller;

  InputField(this.text, this.inputType, this.controller);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 15),
        hintText: text,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        hintStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}
