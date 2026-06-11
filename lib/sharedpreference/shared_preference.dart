import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  static late final SharedPreferences _pref;


  static Future<void> init() async {
    _pref =  await SharedPreferences.getInstance();
  }

  //Theme

  static  final themeChange = 'theme_change';


  static  Future<bool> setTheme(bool changedTheme)  {
    return  _pref.setBool(themeChange, changedTheme);
  }

  static bool getTheme() {
     return _pref.getBool(themeChange) ?? false;
  }


  //Font

  static  final fontChange = 'font_change';

  static  Future<bool> setFont(String isFontChanged) {
    return _pref.setString(fontChange, isFontChanged);
  }

 static String? getFont() {
    return _pref.getString(fontChange);
  }

  Future<bool> removeFont() {
    return _pref.remove(fontChange);
  }


}