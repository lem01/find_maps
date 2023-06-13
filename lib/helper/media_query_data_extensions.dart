import 'package:flutter/material.dart';
import 'dart:math' as math;

extension MediaQueryDataExtentions on MediaQueryData
{
  double get width => size.width;
  double get height => size.height;
  double get diagonal => math.sqrt(math.pow(width, 2) + math.pow(height, 2));

  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;
  double dp(double percent) => diagonal * percent / 100;
}
