import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/user_list_view_model.dart';

class UserFormViewModel extends BaseViewModel with MessageStateMixin {
  final UserRepositoryImpl _userRepository;
  final DepartmentRepositoryImpl _departmentRepository;
  final ProfileRepositoryImpl _profileRespository;
  final CompanyRepositoryImpl _companyRepository;

  UserFormViewModel({
    required UserRepositoryImpl userRepository,
    required DepartmentRepositoryImpl departmentRepository,
    required ProfileRepositoryImpl profileRespository,
    required CompanyRepositoryImpl companyRepository,
  }) : _userRepository = userRepository,
       _departmentRepository = departmentRepository,
       _profileRespository = profileRespository,
       _companyRepository = companyRepository;

  final userListViewModel = Get.find<UserListViewModel>(tag: 'depList');
  final authController = Get.find<AuthController>();
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final userModel = UserModel.empty().obs;
  final availableDepartments = RxList<DepartmentModel>();
  final availableProfiles = RxList<ProfileModel>();
  final availableCompanies = RxList<CompanyModel>();
  final tryAgain = RxBool(false);

  Future<void> initialize(String userId) async {
    pageStatus.value = PageStatusLoading();

    await _loadAvailableDepartments();
    await _loadAvailableProfiles();
    await _loadAvailableCompanies();
    // await Future.delayed(const Duration(seconds: 1));
    if (userId != 'new') {
      if (userListViewModel.userList.isEmpty) {
        await userListViewModel.findAllUsers({});
      }
      final matchingUser = userListViewModel.userList.firstWhereOrNull((activity) => activity.id == userId);
      if (matchingUser != null) {
        pageStatus.value = PageStatusSuccess<Rx<UserModel>>(matchingUser.obs);
      } else {
        showError('Usuário não encontrado');
        pageStatus.value = PageStatusError('Usuário não encontrado');
      }
      return;
    } else {
      pageStatus.value = PageStatusSuccess<Rx<UserModel>>(UserModel.empty().obs);
      return;
    }
  }

  Future<void> _loadAvailableDepartments() async {
    try {
      final result = await _departmentRepository.findAllDepartments({});
      result.fold((RepositoryException re) => showError(re.message), (List<DepartmentModel> departments) {
        if (departments.isNotEmpty) {
          availableDepartments.value = departments;
        }
      });
    } catch (e) {
      showError('Erro ao carregar departamentos');
    }
  }

  Future<void> _loadAvailableProfiles() async {
    try {
      final result = await _profileRespository.findAllProfiles({});
      result.fold((RepositoryException re) => showError(re.message), (List<ProfileModel> profiles) {
        if (profiles.isNotEmpty) {
          availableProfiles.value = profiles;
        }
      });
    } catch (e) {
      showError('Erro ao carregar departamentos');
    }
  }

  Future<void> _loadAvailableCompanies() async {
    try {
      final result = await _companyRepository.findAllCompanies({});
      result.fold((RepositoryException re) => showError(re.message), (List<CompanyModel> companies) {
        availableCompanies.value = companies;
      });
    } catch (e) {
      showError('Erro ao carregar empresas');
    }
  }

  Future<void> saveUser(UserModel model) async {
    try {
      pageStatus.value = PageStatusLoading();
      update();

      // Respito para a tela mudar o status
      await Future.delayed(Duration(milliseconds: 500));

      final user = model.copyWith(createdAt: model.createdAt ?? DateTime.now(), updatedAt: DateTime.now());
      // await Future.delayed(const Duration(seconds: 2));
      final result = await _userRepository.saveUser(userModel: user);
      await result.fold(
        (exception) {
          pageStatus.value = PageStatusSuccess<Rx<UserModel>>(model.obs);
          tryAgain.value = true;
          showError('Erro ao salvar usuário: ${exception.message}');
        },
        (UserModel userModel) async {
          if (model.id != '') {
            final index = userListViewModel.userList.indexWhere((dep) => dep.id == model.id);
            if (index != -1) userListViewModel.userList[index] = userModel;
            userListViewModel.userList.refresh();
          } else {
            userListViewModel.userList.insert(0, user.copyWith(id: userModel.id));
          }
          if (userModel.id == authController.localUserModel.value?.id) {
            await authController.updateLocalUser(userModel);
          }
          pageStatus.value = PageStatusSuccess<Rx<UserModel>>(model.obs);
          tryAgain.value = false;
          showSuccess('Operação realizada com sucesso!');
        },
      );
    } catch (e) {
      showError('Erro ao salvar usuário: $e');
    }
  }
}
