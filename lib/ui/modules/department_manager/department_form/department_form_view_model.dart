import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/models/department/department_status.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';
import 'package:versystems_app/ui/modules/department_manager/department_list/department_list_view_model.dart';

class DepartmentFormViewModel extends BaseViewModel with MessageStateMixin {
  final DepartmentRepositoryImpl _departmentRepository;

  DepartmentFormViewModel({required DepartmentRepositoryImpl departmentRepository}) : _departmentRepository = departmentRepository;

  final departmentListViewModel = Get.find<DepartmentListViewModel>(tag: 'depList');
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final departmentModel = Rx<DepartmentModel>(
    DepartmentModel(
      id: '',
      departmentStatus: DepartmentStatusEnum.active,
      name: '',
      description: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  Future<void> initialize(String departmentId) async {
    pageStatus.value = PageStatusLoading();

    await Future.delayed(const Duration(seconds: 1));
    if (departmentId != 'new') {
      if (departmentListViewModel.departmentList.isEmpty) {
        await departmentListViewModel.findAllDepartments({});
      }
      final matchingDepartment = departmentListViewModel.departmentList.firstWhereOrNull((activity) => activity.id == departmentId);
      if (matchingDepartment != null) {
        pageStatus.value = PageStatusSuccess<DepartmentModel>(matchingDepartment);
      } else {
        showError('Atividade não encontrada');
        pageStatus.value = PageStatusError('Atividade não encontrada');
      }
      return;
    } else {
      pageStatus.value = PageStatusSuccess<DepartmentModel?>(
        DepartmentModel(id: '', departmentStatus: DepartmentStatusEnum.active, name: '', description: '', createdAt: DateTime.now(), updatedAt: null),
      );
      return;
    }
  }

  Future<void> saveDepartment(DepartmentModel model) async {
    try {
      pageStatus.value = PageStatusLoading();
      final department = model.copyWith(createdAt: model.createdAt ?? DateTime.now(), updatedAt: DateTime.now());

      final result = await _departmentRepository.saveDepartment(department);
      result.fold(
        (exception) {
          showError('Erro ao salvar departamento: ${exception.message}');
        },
        (departmentId) {
          showSuccess('Operação realizada com sucesso!');
          pageStatus.value = PageStatusSuccess<DepartmentModel>(departmentModel.value);
          if (model.id != '') {
            final index = departmentListViewModel.departmentList.indexWhere((dep) => dep.id == model.id);
            if (index != -1) {
              departmentListViewModel.departmentList[index] = department;
            }
            departmentListViewModel.departmentList.refresh();
          } else {
            departmentListViewModel.departmentList.insert(0, department.copyWith(id: departmentId));
          }
        },
      );
    } catch (e) {
      showError('Erro ao salvar departamento: $e');
    }
    pageStatus.value = PageStatusSuccess<DepartmentModel>(model);
  }
}
