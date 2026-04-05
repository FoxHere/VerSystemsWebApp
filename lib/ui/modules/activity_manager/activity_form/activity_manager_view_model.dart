import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/repositories/activity/activity_repository_impl.dart';
import 'package:versystems_app/data/repositories/client/client_repository_impl.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_list/activity_list_view_model.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view_model.dart';

class ActivityManagerViewModel extends BaseViewModel with MessageStateMixin {
  final ActivityRepositoryImpl _activityRepositoryImpl;
  final FormularyRepositoryImpl _formularyRepostoryImpl;
  final UserRepositoryImpl _userRepositoryImpl;
  final ClientRepositoryImpl _clientRepositoryImpl;

  ActivityManagerViewModel({
    required ActivityRepositoryImpl activityRepositoryImpl,
    required FormularyRepositoryImpl formularyRepositoryImpl,
    required UserRepositoryImpl userRepositoryImpl,
    required ClientRepositoryImpl clientRepositoryImpl,
  }) : _activityRepositoryImpl = activityRepositoryImpl,
       _formularyRepostoryImpl = formularyRepositoryImpl,
       _userRepositoryImpl = userRepositoryImpl,
       _clientRepositoryImpl = clientRepositoryImpl;

  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final saveActivityStatus = Rx<PageStatus>(PageStatusIdle());
  final activityModel = Rx<ActivityModel>(ActivityModel.empty()); // Talvez eu não use
  final activityListViewModel = Get.find<ActivityListViewModel>();
  final availableFormularyList = RxList<FormularyModel>();
  final availableUsersList = RxList<UserModel>();
  final availableClientsList = RxList<ClientModel>();

  void initialize(String activityId) async {
    pageStatus.value = PageStatusLoading();

    await _loadAvaliableFormularies();
    await _loadAvailableUsers();
    await _loadAvailableClients();

    await Future.delayed(const Duration(seconds: 1));
    if (activityId != 'new') {
      if (activityListViewModel.activities.isEmpty) {
        await activityListViewModel.findAllActivities({});
      }
      final matchingActivity = activityListViewModel.activities.firstWhereOrNull((activity) => activity.id == activityId);
      if (matchingActivity != null) {
        activityModel.value = matchingActivity;
        pageStatus.value = PageStatusSuccess<ActivityModel>(activityModel.value);
      } else {
        showError('Atividade não encontrada');
        pageStatus.value = PageStatusError('Atividade não encontrada');
      }
      return;
    } else {
      pageStatus.value = PageStatusSuccess<ActivityModel>(activityModel.value);
      return;
    }
  }

  Future<void> _loadAvailableClients() async {
    try {
      final result = await _clientRepositoryImpl.findAllClients({});
      result.fold(
        (RepositoryException re) {
          debugPrint('Erro ao carregar clientes: ${re.message}');
          return showError(re.message);
        },
        (List<ClientModel> clientModelList) {
          if (clientModelList.isNotEmpty) {
            availableClientsList.value = clientModelList;
          }
        },
      );
    } catch (e) {
      debugPrint('Erro ao carregar clientes: $e');
      showError('Erro ao carregar clientes');
    }
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final result = await _userRepositoryImpl.findAllUsers({});
      result.fold(
        (RepositoryException re) {
          debugPrint('Erro ao carregar usuários: ${re.message}');
          return showError(re.message);
        },
        (List<UserModel> userModelList) {
          if (userModelList.isNotEmpty) {
            availableUsersList.value = userModelList;
          }
        },
      );
    } catch (e) {
      debugPrint('Erro ao carregar usuários: $e');
      showError('Erro ao carregar usuários');
    }
  }

  Future<void> _loadAvaliableFormularies() async {
    try {
      final result = await _formularyRepostoryImpl.findAllFormularies();
      result.fold(
        (RepositoryException re) {
          debugPrint(re.message);
          return showError(re.message);
        },
        (List<FormularyModel> formularyModelList) {
          if (formularyModelList.isNotEmpty) {
            availableFormularyList.value = formularyModelList;
          }
        },
      );
    } catch (e) {
      debugPrint('Erro ao carregar formulários: $e');
      showError('Erro ao carregar formulários');
    }
  }

  Future<void> onSaveActivity(ActivityModel activityForm) async {
    try {
      pageStatus.value = PageStatusLoading();
      final activity = activityForm.copyWith();
      await Future.delayed(const Duration(seconds: 1));

      // pageStatus.value = PageStatusSuccess<ActivityModel>(activity);
      final result = await _activityRepositoryImpl.saveActivity(activity);
      result.fold(
        (RepositoryException re) {
          showError(re.message);
        },
        (String activityId) {
          final savedActivity = activityForm.id != '' ? activity : activity.copyWith(id: activityId);

          if (activityForm.id != '') {
            final index = activityListViewModel.activities.indexWhere((a) => a.id == activityForm.id);
            if (index != -1) activityListViewModel.activities[index] = savedActivity;
            activityListViewModel.activities.refresh();
          } else {
            activityListViewModel.activities.insert(0, savedActivity);
          }

          if (Get.isRegistered<TaskListViewModel>()) {
            final taskVM = Get.find<TaskListViewModel>();
            if (activityForm.id != '') {
              final taskIndex = taskVM.taskModelList.indexWhere((a) => a.id == activityForm.id);
              if (taskIndex != -1) {
                taskVM.taskModelList[taskIndex] = savedActivity;
                taskVM.taskModelList.refresh();
              }
            } else {
              taskVM.taskModelList.insert(0, savedActivity);
            }
          }

          showSuccess('Atividade salva com sucesso');
          pageStatus.value = PageStatusSuccess<ActivityModel>(savedActivity);
        },
      );
    } catch (e) {
      showError('Erro ao salvar atividade');
    }
  }

  // Create a function to retrieve users from users repository
}
