import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class AppColor {
  static const int white = 0xFFFFFFFF;
  static const int mainTextColor = 0xFF121917;
  static const int subTextColor = 0xFF959595;
  static const int themeColor = 0xFF4DD050;
  static const int backgroundColor = 0xFFFFFFFF;
  static const int bodyColor = 0xFFEFEFEF;
  static const int accentColor = 0xFF888888;

  static const int hightlight = 0xFF4DD050;

  // static const double windowWidth = window.physicalSize.width;

  static Color randomColor() {
    return Color(white & Random().nextInt(white));
  }
}