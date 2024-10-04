import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voices_for_christ/ui/shared_theme.dart';

//Color unselectedColor = darkBlue.withOpacity(0.75);
//Color selectedColor = darkBlue;
Color unselectedColor = Colors.white.withOpacity(0.8);
Color selectedColor = Colors.white;

ThemeData lightTheme = sharedTheme.copyWith(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  hintColor: darkBlue,
  highlightColor: Colors.black,//Color(0xfffa7a0a),
  focusColor: Color(0xfffa7a0a),
  //backgroundColor: Color(0xffe5f6ff).withOpacity(0.5),
  canvasColor: Colors.white,
  //cardColor: Colors.white,
  cardColor: Colors.white,
  scaffoldBackgroundColor: Colors.white.withOpacity(0.75),
  dialogBackgroundColor: Colors.white,
  primaryTextTheme: TextTheme(
    displayLarge: TextStyle(
      color: darkBlue,
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      color: darkBlue,
      fontSize: 20.0,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      color: darkBlue,
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: darkBlue,
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
    ),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    elevation: 0.0,
    iconTheme: IconThemeData(
      color: darkBlue,
    ),
    titleTextStyle: GoogleFonts.montserrat(
      color: darkBlue,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //backgroundColor: Color(0xff000d14),
    backgroundColor: Colors.black,
    elevation: 0.0,
    selectedItemColor: selectedColor,
    unselectedItemColor: unselectedColor,
    selectedLabelStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
    ),
    unselectedLabelStyle: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16.0,
    ),
    selectedIconTheme: IconThemeData(
      color: selectedColor,
    ),
    unselectedIconTheme: IconThemeData(
      color: unselectedColor,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: darkBlue,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: darkBlue,
        width: 1.0,
      ),
    ),
    hintStyle: TextStyle(
      color: darkBlue.withOpacity(0.6),
      fontSize: 18.0,
    ),
  ), bottomAppBarTheme: BottomAppBarTheme(color: Color(0xff013857)),
);