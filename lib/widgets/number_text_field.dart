import 'package:flutter/material.dart';

class NumberTextField extends StatelessWidget {
  NumberTextField({
    super.key,
    required this.onEnteredNumber,
  });

  final void Function(int) onEnteredNumber;

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  String? _validate(String? enteredText) {
    if (enteredText == null) {
      return "Campo vacio";
    }

    if (enteredText.trim().isEmpty) {
      return null;
    }

    var eneteredNumber = int.tryParse(enteredText);
    if (eneteredNumber == null) {
      return 'Debes ingresar un entero';
    }

    if (eneteredNumber < 0) {
      return 'Debe ser mayor a 0';
    }

    return null;
  }

  void _onEditingComplete() {
    if (_formKey.currentState!.validate() && _controller.text.isNotEmpty) {
      _formKey.currentState!.save();

      int enteredNumber = int.parse(_controller.text.toString());
      onEnteredNumber(enteredNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Form(
        key: _formKey,
        child: TextFormField(
          keyboardType: TextInputType.numberWithOptions(),
          controller: _controller,
          validator: _validate,
          onEditingComplete: _onEditingComplete,
          maxLength: 4,
          decoration: InputDecoration(
            label: Text("Número"),
            border: OutlineInputBorder(),
            hintText: "####",
            counterText: "",
          ),
        ),
      ),
    );
  }
}
