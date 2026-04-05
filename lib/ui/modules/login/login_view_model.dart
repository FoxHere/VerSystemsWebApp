import 'package:get/get.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/repositories/auth/auth_repository_impl.dart';

class LoginViewModel extends GetxController with MessageStateMixin {
  final AuthRepositoryImpl authRepository;
  final isLoading = false.obs;

  LoginViewModel({required this.authRepository});

  Future<Either<bool, bool>> login(String email, String password) async {
    isLoading(true);
    try {
      final result = await authRepository.login(
        email: email,
        password: password,
      );
      return result.fold(
        (exception) {
          showError(exception.message);
          return Left(false);
        },
        (logged) {
          showSuccess('Login realizado com sucesso!');
          return Right(true);
        },
      );
    } finally {
      isLoading(false);
    }
  }
}
