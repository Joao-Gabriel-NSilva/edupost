import 'package:flutter/material.dart';
import 'dart:ui';

class UtilStyle {
  static final UtilStyle _utilStyle = UtilStyle._internal();
  UtilStyle._internal();
  static UtilStyle get instance {
    return _utilStyle;
  }

  final Color colorRedLogin = Colors.lightGreen.shade900;
}