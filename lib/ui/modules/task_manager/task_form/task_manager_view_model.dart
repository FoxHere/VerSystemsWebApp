// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/repositories/task/task_repository_impl.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_list/activity_list_view_model.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class TaskManagerViewModel extends BaseViewModel with MessageStateMixin {
  final TaskRepositoryImpl _taskRepositoryImpl;

  TaskManagerViewModel({required TaskRepositoryImpl taskRepositoryImpl}) : _taskRepositoryImpl = taskRepositoryImpl;

  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final taskModel = Rx<ActivityModel?>(null); // Talvez eu não use
  final taskListViewModel = Get.find<TaskListViewModel>();
  final removedImagesList = <ImageItemModel>[].obs;

  void initialize(String taskId) async {
    pageStatus.value = PageStatusLoading();
    if (taskListViewModel.taskModelList.isEmpty) {
      await taskListViewModel.findAllTasks({});
    }
    final matchingTask = taskListViewModel.taskModelList.firstWhereOrNull((task) => task.id == taskId);
    if (matchingTask != null) {
      taskModel.value = matchingTask;
      pageStatus.value = PageStatusSuccess(matchingTask);
    } else {
      debugPrint('Tarefa com o id: $taskId não encontrada');
      showError('Tarefa não encontrada');
      pageStatus.value = PageStatusError('Tarefa não encontrada');
    }
  }

  Future<void> saveTaskForm(FormularyModel formStructure, ActivityStatusEnum newStatus) async {
    pageStatus.value = PageStatusLoading();

    taskModel.value!.formulary = formStructure;
    taskModel.value!.activityStatus = newStatus;

    final result = await _taskRepositoryImpl.saveTask(taskModel.value!, removedImagesList.value, newStatus: newStatus);
    result.fold(
      (exception) {
        showError(exception.message);
        pageStatus.value = PageStatusSuccess(taskModel.value!);
      },
      (unit) {
        final index = taskListViewModel.taskModelList.indexWhere((task) => task.id == taskModel.value!.id);
        if (index != -1) taskListViewModel.taskModelList[index] = taskModel.value!;
        taskListViewModel.taskModelList.refresh();

        if (Get.isRegistered<ActivityListViewModel>()) {
          final activityVM = Get.find<ActivityListViewModel>();
          final activityIndex = activityVM.activities.indexWhere((a) => a.id == taskModel.value!.id);
          if (activityIndex != -1) {
            activityVM.activities[activityIndex] = taskModel.value!;
            activityVM.activities.refresh();
          }
        }

        showSuccess('Tarefa salva com sucesso!');
        removedImagesList.value = [];
        pageStatus.value = PageStatusSuccess(taskModel.value!);
      },
    );
  }
}
