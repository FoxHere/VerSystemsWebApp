import 'package:get/get.dart';
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';

class UserListViewModel extends BaseViewModel with MessageStateMixin {
  final UserRepositoryImpl _userRepository;

  UserListViewModel({required UserRepositoryImpl userRepository}) : _userRepository = userRepository;

  final userList = <UserModel>[].obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());

  @override
  void onInit() {
    super.onInit();
    findAllUsers({});
  }

  Future<void> findAllUsers(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    await Future.delayed(const Duration(milliseconds: Boudaries.delayMilliseconds));
    final result = await _userRepository.findAllUsers(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<UserModel> users) {
        if (users.isEmpty) {
          pageStatus.value = PageStatusEmpty(title: 'Não existem departamentos cadastrados');
          return;
        }
        userList.assignAll(users);
        pageStatus.value = PageStatusSuccess<List<UserModel>>(userList);
      },
    );
  }

  Future<void> deleteUser(String id) async {
    final result = await _userRepository.deleteUser(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar departamento: ${exception.message}');
      },
      (unit) {
        showSuccess('Departamento deletado com sucesso!');
        userList.removeWhere((user) => user.id == id);
        userList.refresh();
        update();
      },
    );
  }
}
