import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdfconverter/assets/colors/ThemeColors.dart';

class PrefsManager extends Settings {
  static final PrefsManager _instance = PrefsManager._internal();
  GetStorage box;

  factory PrefsManager() {
    return _instance;
  }

  get getThemeColor => themeColor;

  get getAccentColor => accentColor;

  get getTextStyle => textStyle;

  get getDarkAccentColor => darkAccentColor;

  get getGridCount => gridCount;

  set setThemeColor(Color val) {
    themeColor = val;
    box.write("themeColor", themeColor.value);
  }

  set setAccentColor(Color val) {
    accentColor = val;
    box.write("accentColor", accentColor.value);
  }

  set setDarkAccentColor(Color val) {
    darkAccentColor = val;
    box.write("darkAccentColor", darkAccentColor.value);
  }

  set setTextStyle(String val) {
    textStyle = val;
    box.write("textStyle", textStyle);
  }

  set setGridCount(int val) {
    gridCount = val;
    box.write("gridCount", gridCount);
  }

  PrefsManager._internal() {
    box = GetStorage('PrefsManager');
    themeColor = Color(box.read('themeColor') ?? Colors.black.value) ?? Colors.black;
    accentColor = Color(box.read('accentColor') ?? Colors.white.value) ?? Colors.white;
    darkAccentColor =
        Color(box.read('darkAccentColor') ?? Colors.lightBlue.value) ?? Colors.lightBlue;
    textStyle = box.read('textStyle') ?? 'DM_Mono';
    gridCount = box.read("gridCount") ?? 3;
  }
}

class Settings {
  Color themeColor;
  Color accentColor;
  Color darkAccentColor;
  String textStyle;
  int gridCount;
}
