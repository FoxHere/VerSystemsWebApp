import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';

class HomeViewModel extends GetxController with MessageStateMixin {
  final isLoading = false.obs;

  HomeViewModel();
  final authController = Get.find<AuthController>();
}
