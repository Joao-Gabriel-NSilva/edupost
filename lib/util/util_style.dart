import 'package:flutter/material.dart';
import 'dart:ui';

import '../cache/shared_preferences_helper.dart';
import '../cache/theme_manager.dart';

class UtilStyle {
  static final UtilStyle _utilStyle = UtilStyle._internal();
  UtilStyle._internal();
  static UtilStyle get instance{
    return _utilStyle;
  }
  ThemeManager themeManager = ThemeManager.instance;

  static String? tema;

  final Color corPrimaria = const Color.fromRGBO(27, 94, 32, 1);
  final Color corErro = const Color.fromRGBO(186, 26, 26, 1);

  Color get backGroundColor {
    return !themeManager.isDarkMode ? whiteThemeBackground : darkThemeBackGround;
  }
  Color get foreGroundColor {
    return !themeManager.isDarkMode ? whiteThemeForeground : darkThemeForeGround;
  }
  Color get tileColor {
    return !themeManager.isDarkMode ? whiteThemeTileColor : darkThemeTileColor;
  }
  Color get titleColor {
    return !themeManager.isDarkMode ? whiteThemeTitleColor : darkThemeTitleColor;
  }
  Color get subTitleColor {
    return !themeManager.isDarkMode ? whiteThemeSubTitleColor : darkThemeSubTitleColor;
  }
  Color get textFieldBackGroundColor {
    return !themeManager.isDarkMode ? whiteThemeTextFieldColor : darkThemeTextFieldColor;
  }

  final Color darkThemeBackGround = const Color.fromRGBO(23, 23, 23, 1);
  final Color darkThemeForeGround = Colors.white;
  final Color darkThemeTileColor = Colors.black26;
  final Color darkThemeTitleColor = Colors.white;
  final Color darkThemeSubTitleColor = Colors.white38;
  final Color darkThemeTextFieldColor = Colors.black38;

  final Color whiteThemeBackground = Colors.white;
  final Color whiteThemeForeground = Colors.black;
  final Color whiteThemeTileColor = Colors.transparent;
  final Color whiteThemeTitleColor = Colors.black;
  final Color whiteThemeSubTitleColor = Colors.grey;
  final Color whiteThemeTextFieldColor = Colors.white38;

  void setarTema() async {
    themeManager.toggleDarkMode();
  }


}