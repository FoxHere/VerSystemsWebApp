import 'package:get/get.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/dashboard/dashboard_model.dart';
import 'package:versystems_app/data/repositories/dashboard/dashboard_repository_impl.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';

class DashboardViewModel extends BaseViewModel with MessageStateMixin {
  final DashboardRepositoryImpl _dashboardRepository;
  final CompanyRepositoryImpl _companyRepositoryImpl = Get.find<CompanyRepositoryImpl>();

  DashboardViewModel({required DashboardRepositoryImpl dashboardRepository}) : _dashboardRepository = dashboardRepository;

  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final currentCompanyName = ''.obs;
  DateTime? _lastUpdate;
  final Duration _updateInterval = const Duration(minutes: 1);

  Future<void> findAllDashboardData(String id) async {
    pageStatus.value = PageStatusLoading();

    /// Aqui precisaremos colocar um tipo de limitador para atualizar o dashboard a cada x minutos
    _maybeUpdateBackgroundDashboard();

    // Fetch company name
    final companyId = AppSessionController.instance.companyId;
    if (companyId.isNotEmpty) {
      final compResult = await _companyRepositoryImpl.findOneById(companyId);
      compResult.fold(
        (l) => null,
        (company) {
          if (company != null) currentCompanyName.value = company.name;
        }
      );
    }

    final result = await _dashboardRepository.findOneDashboard(id);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (DashboardModel? dashboard) {
        if (dashboard == null) {
          pageStatus.value = PageStatusEmpty(title: 'Dashboard não encontrado');
          return;
        }
        pageStatus.value = PageStatusSuccess(dashboard);
      },
    );
  }

  Future<void> _updateBackgroundDashboard() async {
    await _dashboardRepository.updateDashboard();
  }

  Future<void> _maybeUpdateBackgroundDashboard() async {
    final now = DateTime.now();
    if (_lastUpdate == null || now.difference(_lastUpdate!) > _updateInterval) {
      await _updateBackgroundDashboard();
      _lastUpdate = now;
    }
  }
}
