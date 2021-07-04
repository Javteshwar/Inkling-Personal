import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  primaryColor: Colors.green,
  brightness: Brightness.dark,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white70,
    hintStyle: TextStyle(color: Colors.black54),
    labelStyle: TextStyle(
      fontSize: 16,
      color: Colors.blue[800],
    ),
    errorStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Color.fromRGBO(225, 6, 0, 1),
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.green[500],
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.green[500],
        width: 4,
      ),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
      ),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 4,
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.shifting,
    showSelectedLabels: true,
    showUnselectedLabels: false,
    selectedIconTheme: IconThemeData(
      color: Colors.white,
      size: 28,
    ),
    unselectedIconTheme: IconThemeData(
      color: Colors.black,
      size: 24,
    ),
    selectedLabelStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      color: Colors.black,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Colors.blue[800],
      minimumSize: Size(150, 50),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  dialogBackgroundColor: Colors.blue[800],
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: TextStyle(
        color: Colors.white,
      ),
    ),
  ),
);
