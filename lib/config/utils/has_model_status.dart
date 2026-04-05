import 'package:flutter/material.dart';

abstract class HasModelStatus<T extends StatusVisual> {
  String get id;
  T get status;
}

abstract class StatusVisual {
  Color get color;
  Color get backgroundColor;
  String get label;
  LinearGradient get gradient;
}
