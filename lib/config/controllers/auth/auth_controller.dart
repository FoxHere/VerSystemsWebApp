import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';

// Vou centralizar a logica aqui dentro assim o controlador será passado para as partes da aplicação que precisarem dos dados
class AuthController extends GetxController {
  final UserRepositoryImpl _userRepositoryImpl;
  final AuthRepositoryImpl authRepositoryImpl;

  AuthController({required UserRepositoryImpl userRepositoryImpl, required this.authRepositoryImpl}) : _userRepositoryImpl = userRepositoryImpl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  // essa variável será apenas atualizada se usuário estiver logado e se houver dados do usuário.
  final isInitialized = false.obs;
  final localUserModel = Rxn<UserModel?>();

  // Um getter para facilitar a exibição da imagem do perfil
  String? get profileImageDisplayURL => localUserModel.value?.profileImage?.downloadUrl;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    initializeIt();
  }

  Future<bool> initializeIt() async {
    // Verifica se usuário está autenticado no firebase auth
    bool isAuthenticatedOnFirebase = firebaseUser.value != null;
    if (!isAuthenticatedOnFirebase) {
      isInitialized.value = false;
      return false;
    }

    // Verifica se os dados do usuário estão salvos no security store
    final userResult = await _userRepositoryImpl.loadUserDataFromSecurityStorage();
    if (isAuthenticatedOnFirebase && userResult == null) {
      _auth.signOut();
      isInitialized.value = false;
      return false;
    }
    localUserModel.value = userResult;

    // Restaura o companyId da sessão (usuário já estava logado)
    if (userResult != null && userResult.company.isNotEmpty) {
      AppSessionController.instance.setCompanyId(userResult.company);
    }

    isInitialized.value = true;
    return true;
  }

  Future<void> updateLocalUser(UserModel userModel) async {
    await _userRepositoryImpl.saveUserDataToSecurityStorage(userModel);
    localUserModel.value = userModel;
    return;
  }

  Future<void> logout() async {
    await authRepositoryImpl.logout();
    isInitialized.value = false;
  }
}
