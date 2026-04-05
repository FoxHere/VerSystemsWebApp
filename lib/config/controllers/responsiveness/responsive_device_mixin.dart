import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_controller.dart';

mixin ResponsiveDeviceMixin<T extends StatefulWidget> on State<T> {
  final ResponsiveController _responsiveController = Get.find<ResponsiveController>();

  Size get size => MediaQuery.of(context).size;

  bool get isLargeScreen => _responsiveController.isLargeDevice.value;
  bool get isMediumScreen => _responsiveController.isMediumDevice.value;
  bool get isSmallScreen => _responsiveController.isSmallDevice.value;

  void updateScreenSize() {
    final screenWidth = size.width;
    _responsiveController.updateDeviceSize(screenWidth);
  }
}
