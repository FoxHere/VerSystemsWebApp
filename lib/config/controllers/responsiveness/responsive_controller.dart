import 'package:get/get.dart';

class ResponsiveController extends GetxController {
  static const int mediumScreenBreakpoint = 1440;
  static const int smallScreenBreakpoint = 800;
  final isLargeDevice = false.obs;
  final isMediumDevice = false.obs;
  final isSmallDevice = false.obs;

  void updateDeviceSize(double width) {
    isLargeDevice(width >= mediumScreenBreakpoint);
    isMediumDevice(width <= mediumScreenBreakpoint && width >= smallScreenBreakpoint);
    isSmallDevice(width <= smallScreenBreakpoint);
  }
}
