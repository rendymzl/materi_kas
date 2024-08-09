import 'package:flutter/services.dart';

class CustomNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Remove any characters that are not digits or comma
    text = text.replaceAll(RegExp(r'[^0-9,]'), '');

    // Split the input by the comma to separate integer and decimal parts
    List<String> parts = text.split(',');

    // Format the integer part with dots
    if (parts[0].length > 3) {
      parts[0] = parts[0]
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    }

    // Join back the parts
    text = parts.join(',');

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
