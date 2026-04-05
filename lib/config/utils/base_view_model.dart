import 'package:get/get.dart';

abstract class BaseViewModel extends GetxController {
  Future<T> executeWithLoading<T>(RxBool loadingState, Future<T> Function() action) async {
    loadingState(true);
    try {
      return await action();
    } finally {
      loadingState(false);
    }
  }
}
