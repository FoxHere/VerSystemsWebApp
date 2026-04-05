import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class UserProfileViewModel extends GetxController with MessageStateMixin {
  final UserRepositoryImpl _userRepository;
  final AuthController _authController;

  final isLoading = false.obs;

  UserProfileViewModel({required UserRepositoryImpl userRepository, required AuthController authController})
    : _userRepository = userRepository,
      _authController = authController;

  /// Atualiza apenas a foto de perfil do usuário
  Future<void> updateProfileImage(ImageItemModel image) async {
    try {
      isLoading.value = true;
      final currentUser = _authController.localUserModel.value;
      if (currentUser == null) {
        showError('Usuário não encontrado');
        return;
      }
      // Faz upload da imagem
      final uploadResult = await _userRepository.uploadImage(image, currentUser.id);
      uploadResult.fold(
        (error) {
          showError(error.message);
          return;
        },
        (uploadResult) async {
          final updatedUser = currentUser.copyWith(
            profileImage: ImageItemModel(
              bytes: Uint8List(0),
              name: uploadResult.name,
              sizeBytes: uploadResult.sizeBytes,
              downloadUrl: uploadResult.downloadUrl,
              fullPath: uploadResult.fullPath,
              bucket: uploadResult.bucket,
            ),
            updatedAt: DateTime.now(),
          );
          final saveResult = await _userRepository.saveUser(userModel: updatedUser);
          saveResult.fold((error) => showError(error.message), (updatedUserModel) => _authController.updateLocalUser(updatedUserModel));
        },
      );
    } catch (e) {
      showError('Erro ao atualizar foto de perfil: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
