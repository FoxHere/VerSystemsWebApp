import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/repositories/department/department_repository_impl.dart';

class DepartmentListViewModel extends BaseViewModel with MessageStateMixin {
  final DepartmentRepositoryImpl _departmentRepository;

  DepartmentListViewModel({required DepartmentRepositoryImpl departmentRepository}) : _departmentRepository = departmentRepository;

  final departmentList = <DepartmentModel>[].obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());

  @override
  void onInit() {
    super.onInit();
    findAllDepartments({});
  }

  Future<void> findAllDepartments(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    await Future.delayed(const Duration(seconds: 1));
    final result = await _departmentRepository.findAllDepartments(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<DepartmentModel> departments) {
        if (departments.isEmpty) {
          pageStatus.value = PageStatusEmpty(title: 'Não existem departamentos cadastrados');
          return;
        }
        departmentList.assignAll(departments);
        pageStatus.value = PageStatusSuccess<List<DepartmentModel>>(departmentList);
      },
    );
  }

  Future<void> deleteDepartment(String id) async {
    final result = await _departmentRepository.deleteDepartment(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar departamento: ${exception.message}');
      },
      (unit) {
        showSuccess('Departamento deletado com sucesso!');
        departmentList.removeWhere((department) => department.id == id);
        departmentList.refresh();
        update();
      },
    );
  }
}
