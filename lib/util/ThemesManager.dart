import 'package:flutter/material.dart';
import 'package:pdfconverter/assets/colors/Swatchers.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';

import 'PrefsManager.dart';

class ThemesManager with ChangeNotifier {
  static final ThemesManager _instance = ThemesManager._internal();

  factory ThemesManager() {
    return _instance;
  }

  PrefsManager prefsManager;

  ThemesManager._internal() {
    prefsManager = PrefsManager();
    _font = prefsManager.textStyle;
    _themeColor = prefsManager.themeColor;
    _accentColor = prefsManager.accentColor;
    _darkAccentColor = prefsManager.darkAccentColor;
  }

  String _font;
  Color _themeColor;
  Color _accentColor;
  Color _darkAccentColor;

  ThemeData get lightTheme {
    return ThemeData(
        primaryColor: _themeColor,
        scaffoldBackgroundColor: _themeColor,
        accentColor: _accentColor,
        primaryColorDark: _darkAccentColor,
        appBarTheme: appBarTheme(),
        checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all(_darkAccentColor),
        ),
        iconTheme: IconThemeData(
          color: _darkAccentColor,
          size: 16,
        ),
        fontFamily: _font,
        textTheme: textTheme(),
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: _darkAccentColor,
        ));
  }

  AppBarTheme appBarTheme() {
    return AppBarTheme(
      color: _darkAccentColor,
      textTheme: textTheme(),
      iconTheme: IconThemeData(
        color: _darkAccentColor,
        size: 14,
      ),
    );
  }

  TextTheme textTheme() {
    return TextTheme(
        headline1: TextStyle(
            fontFamily: _font,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _darkAccentColor),
        headline2: TextStyle(
            fontFamily: _font,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _darkAccentColor),
        headline3: TextStyle(
            fontFamily: _font,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkAccentColor),
        headline4: TextStyle(
            fontFamily: _font,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _accentColor),
        headline5: TextStyle(
            fontFamily: _font,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _accentColor),
        headline6: TextStyle(
            fontFamily: _font,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _accentColor));
  }

  String get font => prefsManager.getTextStyle;

  set font(String value) {
    _font = value;
    prefsManager.setTextStyle = value;
    notifyListeners();
  }

  Color get themeColor => prefsManager.getThemeColor;

  set themeColor(Color value) {
    _themeColor = value;
    prefsManager.setThemeColor = value;
    notifyListeners();
  }

  Color get accentColor => prefsManager.getAccentColor;

  set accentColor(Color value) {
    _accentColor = value;
    prefsManager.setAccentColor = value;
    notifyListeners();
  }

  Color get darkAccentColor => prefsManager.getDarkAccentColor;

  set darkAccentColor(Color value) {
    _darkAccentColor = value;
    prefsManager.setDarkAccentColor = value;
    notifyListeners();
  }
}
