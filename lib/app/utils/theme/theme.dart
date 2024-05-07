import 'package:flutter/material.dart';
import 'package:materi_kas/app/utils/theme/custom_theme/elevated_button_theme.dart';
import 'package:materi_kas/app/utils/theme/custom_theme/outlined_button_theme.dart';
import 'package:materi_kas/app/utils/theme/custom_theme/text_button_theme.dart';
import 'package:materi_kas/app/utils/theme/custom_theme/text_theme.dart';

import 'custom_theme/card_theme.dart';

class MAppTheme {
  MAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFEF233C),
      onPrimary: Color(0xFFF5F8FF),
      secondary: Color(0xFF8D99AE),
      onSecondary: Color(0xFFF5F8FF),
      error: Color(0xFFba1a1a),
      onError: Color(0xFFF5F8FF),
      background: Color(0xFFF5F8FF),
      onBackground: Color(0xff281717),
      surface: Color(0xfffff8f7),
      onSurface: Color(0xff281717),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F8FF),
    textTheme: MTextTheme.lightTextTheme,
    elevatedButtonTheme: MElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: MEOutlinedButtonTheme.lightOutlinedButtonTheme,
    textButtonTheme: MTextButtonTheme.lightTextButtonTheme,
    cardTheme: MCardTheme.lightCardTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.amber,
    scaffoldBackgroundColor: Colors.black,
    textTheme: MTextTheme.darkTextTheme,
    elevatedButtonTheme: MElevatedButtonTheme.darkElevatedButtonTheme,
  );
}
