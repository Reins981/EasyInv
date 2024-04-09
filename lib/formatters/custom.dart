// Define a custom input formatter to allow only digits or digits and a single dot
import 'package:flutter/services.dart';

class CustomInputFormatter extends TextInputFormatter {
  bool intOnly = false;
  CustomInputFormatter({required this.intOnly});
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits and a single dot
    final regExp = intOnly ? RegExp(r'^(?!0$)\d*$') : RegExp(r'^\d*\.?\d*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    // Return the old value if the new value doesn't match the pattern
    return oldValue;
  }
}