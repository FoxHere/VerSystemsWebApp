import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/repositories/task/task_repository_impl.dart';

enum TaskFilterType { pending, completed, inactive }

extension TaskFilterTypeExtension on TaskFilterType {
  int get index {
    switch (this) {
      case TaskFilterType.pending:
        return 0;
      case TaskFilterType.completed:
        return 1;
      case TaskFilterType.inactive:
        return 2;
    }
  }
}

class TaskListViewModel extends BaseViewModel with MessageStateMixin {
  final TaskRepositoryImpl _taskRepositoryImpl;

  TaskListViewModel({required TaskRepositoryImpl taskRepositoryImpl}) : _taskRepositoryImpl = taskRepositoryImpl;

  final taskModelList = <ActivityModel>[].obs;
  final filteredTaskModelList = <ActivityModel>[].obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final currentUserId = Get.find<AuthController>().localUserModel.value?.id;
  final bottomNavigationBarIndex = 0.obs;
  final currentTab = 0.obs;
  List<ActivityModel> smallScreenFilter(List<ActivityModel> all, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return all.where((t) => t.activityStatus == ActivityStatusEnum.active || t.activityStatus == ActivityStatusEnum.editing).toList();
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
    findAllTasks({'userId': currentUserId});
  }

  void changeTab(int index) async {
    if (currentTab.value == index) return;
    currentTab.update((value) {
      value = index;
    });
    bottomNavigationBarIndex.update((value) {
      value = index;
    });
  }

  /// Atualiza o pageStatus baseado no tamanho da lista filtrada
  void updatePageStatusBasedOnList() {
    if (filteredTaskModelList.isEmpty) {
      pageStatus.value = PageStatusEmpty(title: 'Nenhuma tarefa encontrada');
    } else {
      pageStatus.value = PageStatusSuccess<List<ActivityModel>>(filteredTaskModelList);
    }
  }

  Future<void> findAllTasks(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    final result = await _taskRepositoryImpl.findAllTasks(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<ActivityModel> taskStructure) {
        if (taskStructure.isEmpty) {
          return pageStatus.value = PageStatusEmpty(title: 'Hora de descansar! ☕', description: 'Não existem nenhuma Tarefa para você nesse momento');
        }
        taskModelList.assignAll(taskStructure);
        filteredTaskModelList.assignAll(taskStructure);
        pageStatus.value = PageStatusSuccess<List<ActivityModel>>(taskModelList);
      },
    );
  }

  void showWarningMessage(String message) {
    showWarning(message);
  }
}
