import 'package:flutter/material.dart';
import 'package:accesosqr/components/text_field_container.dart';
import 'package:accesosqr/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType it;
  final TextEditingController controlador;
  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.it,
    this.controlador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: controlador,
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        keyboardType: it,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
