import 'package:flutter/material.dart';

class MEOutlinedButtonTheme {
  MEOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      // foregroundColor: Colors.white,
      // backgroundColor: const Color.fromRGBO(252, 58, 67, 1),
      // disabledBackgroundColor: Colors.grey,
      // disabledForegroundColor: Colors.grey,
      padding: const EdgeInsets.all(20),
      textStyle: const TextStyle(
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.grey)),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromRGBO(252, 58, 67, 1),
      disabledBackgroundColor: Colors.grey,
      disabledForegroundColor: Colors.grey,
      padding: const EdgeInsets.all(15),
      textStyle: const TextStyle(
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
