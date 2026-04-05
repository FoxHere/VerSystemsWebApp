import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/models/department/department_status.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/models/profile/profile_status.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';

class SetupViewModel extends BaseViewModel with MessageStateMixin {
  final CompanyRepositoryImpl _companyRepository;
  final DepartmentRepositoryImpl _departmentRepository;
  final ProfileRepositoryImpl _profileRepository;
  final UserRepositoryImpl _userRepository;
  final AppSessionController _appSessionController;

  SetupViewModel({
    required CompanyRepositoryImpl companyRepository,
    required DepartmentRepositoryImpl departmentRepository,
    required ProfileRepositoryImpl profileRepository,
    required UserRepositoryImpl userRepository,
    required AppSessionController appSessionController,
  }) : _companyRepository = companyRepository,
       _departmentRepository = departmentRepository,
       _profileRepository = profileRepository,
       _userRepository = userRepository,
       _appSessionController = appSessionController;

  final currentStep = 0.obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final isSaving = false.obs;

  void nextStep() {
    if (currentStep.value < 1) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  /// Lista completa de menus do sistema — todos os acessos para o perfil Admin
  static const List<String> _allMenuRoutes = [
    RoutesHelper.dashboard,
    RoutesHelper.formularies,
    RoutesHelper.activities,
    RoutesHelper.tasks,
    RoutesHelper.departments,
    RoutesHelper.users,
    RoutesHelper.profiles,
    RoutesHelper.clients,
    RoutesHelper.companies,
    RoutesHelper.settings,
  ];

  /// Cria o departamento padrão "Geral" e retorna seu ID
  Future<String?> _createDefaultDepartment() async {
    final dept = DepartmentModel(
      id: '',
      departmentStatus: DepartmentStatusEnum.active,
      name: 'Geral',
      description: 'Departamento padrão do sistema',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await _departmentRepository.saveDepartment(dept);
    return result.fold((e) => null, (id) => id);
  }

  /// Cria o perfil padrão "Administrador" com todos os acessos e retorna o modelo com ID
  Future<ProfileModel?> _createDefaultProfile() async {
    final profile = ProfileModel(
      id: '',
      profileStatus: ProfileStatusEnum.active,
      name: 'Administrador',
      description: 'Perfil padrão com acesso total ao sistema',
      level: 1000,
      allowedMenus: _allMenuRoutes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await _profileRepository.saveProfile(profile);
    return result.fold((RepositoryException e) => null, (String id) => profile.copyWith(id: id));
  }

  Future<bool> saveAll({required CompanyModel company, required UserModel adminUser}) async {
    isSaving.value = true;
    pageStatus.value = PageStatusLoading();

    try {
      // 1. Salva a empresa
      final companyToSave = company.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now());
      final companyResult = await _companyRepository.saveCompany(companyToSave);

      late String companyId;
      final companyError = companyResult.fold(
        (RepositoryException e) {
          showError('Erro ao salvar empresa: ${e.message}');
          pageStatus.value = PageStatusError(e.message);
          return true;
        },
        (String id) {
          companyId = id;
          return false;
        },
      );
      // insere a empresa na sessão
      _appSessionController.setCompanyId(companyId);
      if (companyError) {
        isSaving.value = false;
        return false;
      }

      // 2. Cria o departamento padrão "Geral"
      final departmentId = await _createDefaultDepartment();
      if (departmentId == null) {
        showError('Erro ao criar o departamento padrão. Tente novamente.');
        pageStatus.value = PageStatusError('Erro ao criar departamento padrão');
        isSaving.value = false;
        return false;
      }

      // 3. Cria o perfil padrão "Administrador" com todos os menus
      final adminProfile = await _createDefaultProfile();
      if (adminProfile == null) {
        showError('Erro ao criar o perfil de administrador. Tente novamente.');
        pageStatus.value = PageStatusError('Erro ao criar perfil padrão');
        isSaving.value = false;
        return false;
      }

      // 4. Monta o departamento com ID real para vincular ao usuário
      final defaultDepartment = DepartmentModel(
        id: departmentId,
        departmentStatus: DepartmentStatusEnum.active,
        name: 'Geral',
        description: 'Departamento padrão do sistema',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 5. Salva o usuário administrador vinculado à empresa, dept e perfil padrão
      final userToSave = adminUser.copyWith(
        company: companyId,
        department: defaultDepartment,
        profile: adminProfile,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final userResult = await _userRepository.saveUser(userModel: userToSave, isFirstUser: true);

      final userError = userResult.fold(
        (RepositoryException e) {
          showError('Empresa criada, mas erro ao salvar usuário: ${e.message}');
          pageStatus.value = PageStatusError(e.message);
          return true;
        },
        (UserModel _) {
          showSuccess('Configuração inicial concluída com sucesso!');
          pageStatus.value = PageStatusSuccess<bool>(true);
          return false;
        },
      );

      isSaving.value = false;
      return !userError;
    } catch (e) {
      showError('Erro inesperado: $e');
      pageStatus.value = PageStatusError(e.toString());
      isSaving.value = false;
      return false;
    }
  }
}
