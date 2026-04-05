import 'dart:ui';

import 'package:get/get.dart';

abstract class AutoDisposeBindings extends Bindings {
  final List<VoidCallback> _disposeCallbacks = [];

  List<VoidCallback> get disposeCallbacks => _disposeCallbacks;

  void autoLazyPut<T>(T dependecy, {String? tag, bool permanent = false}) {
    Get.lazyPut(() => dependecy, tag: tag, fenix: permanent);
    _disposeCallbacks.add(() => Get.delete<T>(tag: tag));
  }

  void autoPut<T>(T dependecy, {String? tag, bool permanent = false}) {
    Get.put(dependecy, tag: tag, permanent: permanent);
    _disposeCallbacks.add(() => Get.delete<T>(tag: tag));
  }
}
