import 'package:flutter/material.dart';

ThemeData dark({Color color = const Color(0xFF54b46b)}) => ThemeData(
  fontFamily: 'Roboto',
  primaryColor: color,
  secondaryHeaderColor: Color(0xFF009f67),
  disabledColor: Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: Color(0xFFbebebe),
  cardColor: Colors.black,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)), colorScheme: ColorScheme.dark(primary: color, secondary: color).copyWith(background: Color(0xFF343636)).copyWith(error: Color(0xFFdd3135)),
);
