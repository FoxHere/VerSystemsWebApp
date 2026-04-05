import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/repositories/activity/activity_repository_impl.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view_model.dart';

class ActivityListViewModel extends BaseViewModel with MessageStateMixin {
  final ActivityRepositoryImpl _activityRepository;

  ActivityListViewModel({required ActivityRepositoryImpl activityRepository}) : _activityRepository = activityRepository;

  final activities = RxList<ActivityModel>();
  final filteredActivities = RxList<ActivityModel>();
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final bottomNavigationBarIndex = 0.obs;
  final currentTab = 0.obs;
  List<ActivityModel> smallScreenFilter(List<ActivityModel> all, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return all.where((t) => t.activityStatus == ActivityStatusEnum.active).toList();
      case 1:
        return all.where((t) => t.activityStatus == ActivityStatusEnum.done).toList();
      case 2:
        return all.where((t) => t.activityStatus == ActivityStatusEnum.inactive).toList();
    }
    return [];
  }

  @override
  void onInit() {
    super.onInit();
    findAllActivities({});
  }

  void changeTab(int index) async {
    currentTab.update((value) {
      value = index;
    });
  }

  /// Atualiza o pageStatus baseado no tamanho da lista filtrada
  void updatePageStatusBasedOnList() {
    if (filteredActivities.isEmpty) {
      pageStatus.value = PageStatusEmpty(title: 'Nenhuma atividade encontrada');
    } else {
      pageStatus.value = PageStatusSuccess<List<ActivityModel>>(filteredActivities);
    }
  }

  Future<void> findAllActivities(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    final result = await _activityRepository.findAllActivities(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<ActivityModel> taskStructure) {
        if (taskStructure.isEmpty) {
          return pageStatus.value = PageStatusEmpty(title: 'Não existem nenhuma Atividade cadastrada');
        }
        activities.assignAll(taskStructure);
        filteredActivities.assignAll(taskStructure);
        pageStatus.value = PageStatusSuccess<RxList<ActivityModel>>(activities);
      },
    );
  }

  Future<void> changeActivityStatus(ActivityModel activity) async {
    // if (activity.status != ActivityStatusEnum.editing &&
    //     activity.status != ActivityStatusEnum.inactive &&
    //     activity.status != ActivityStatusEnum.active) {
    //   showError(
    //     'Não é possível alterar o status de uma atividade já finalizada',
    //   );
    //   return;
    // }
    final newStatus = activity.activityStatus == ActivityStatusEnum.inactive
        ? ActivityStatusEnum.active
        : activity.activityStatus == ActivityStatusEnum.active
        ? ActivityStatusEnum.inactive
        : activity.activityStatus == ActivityStatusEnum.editing
        ? ActivityStatusEnum.active
        : ActivityStatusEnum.inactive;

    final updatedActivity = activity.copyWith(activityStatus: newStatus);
    // final index = activities.indexWhere((a) => a.id == updatedActivity.id);
    // if (index != -1) {
    //   activities[index] = updatedActivity;
    //   activities.refresh();
    // }
    //-------------------------------------------------------------------------
    final result = await _activityRepository.updateActivityStatus(updatedActivity);
    result.fold(
      (exception) {
        showError(exception.message);
      },
      (unit) {
        final index = activities.indexWhere((a) => a.id == updatedActivity.id);
        if (index != -1) {
          activities[index] = updatedActivity;
          activities.refresh();
        }
        if (Get.isRegistered<TaskListViewModel>()) {
          final taskVM = Get.find<TaskListViewModel>();
          final taskIndex = taskVM.taskModelList.indexWhere((a) => a.id == updatedActivity.id);
          if (taskIndex != -1) {
            taskVM.taskModelList[taskIndex] = updatedActivity;
            taskVM.taskModelList.refresh();
          }
        }
        if (newStatus == ActivityStatusEnum.inactive) {
          showWarning('A atividade ${activity.name} foi desativada');
        } else {
          showSuccess('A atividade ${activity.name} foi ativada');
        }
      },
    );
  }

  Future<void> deleteActivity(String id) async {
    final result = await _activityRepository.deleteActivity(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar atividade: ${exception.message}');
      },
      (unit) {
        showSuccess('Atividade deletada com sucesso!');
        activities.removeWhere((profile) => profile.id == id);
        activities.refresh();
        if (Get.isRegistered<TaskListViewModel>()) {
          final taskVM = Get.find<TaskListViewModel>();
          taskVM.taskModelList.removeWhere((task) => task.id == id);
          taskVM.taskModelList.refresh();
        }
        updatePageStatusBasedOnList();
        update();
      },
    );
  }

  Future<bool> canEditActivity(String activityId) async {
    final activity = activities.firstWhere((activity) => activity.id == activityId);
    if (activity.activityStatus != ActivityStatusEnum.editing && activity.activityStatus != ActivityStatusEnum.inactive) {
      showWarning('Só é possível editar atividades inativas');
      return false;
    }
    return true;
  }
}
