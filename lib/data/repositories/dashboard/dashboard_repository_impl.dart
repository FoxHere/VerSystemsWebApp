import 'dart:developer';

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/dashboard/dashboard_model.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_services_impl.dart';

class DashboardRepositoryImpl {
  final DashboardServicesImpl _dashBoardServices;
  final DashboardFunctionsService _dashboardFunctionsService;

  DashboardRepositoryImpl({required DashboardServicesImpl dashBoardServices, required DashboardFunctionsService dashboardFunctionsService})
    : _dashBoardServices = dashBoardServices,
      _dashboardFunctionsService = dashboardFunctionsService;

  Future<Either<RepositoryException, DashboardModel?>> findOneDashboard(String id) async {
    try {
      final result = await _dashBoardServices.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> dashboard) {
          if (dashboard.isEmpty) return Right(null);
          final DashboardModel dashboardModel = DashboardModel.fromJson(dashboard);
          return Right(dashboardModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório, erro: ${e.toString()}'));
    }
  }

  Future<Either<RepositoryException, List<DashboardModel>>> findAllDashboards(Map<String, dynamic> filters) async {
    try {
      final result = await _dashBoardServices.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> dashboards) {
          if (dashboards.isEmpty) return Right(<DashboardModel>[]);
          final dashboardModelList = dashboards.map((dashboardMap) => DashboardModel.fromJson(dashboardMap)).toList();
          return Right(dashboardModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório, erro: ${e.toString()}'));
    }
  }

  /// Atualiza o dashboard após mudanças nas tarefas
  Future<void> updateDashboard() async {
    try {
      await _dashboardFunctionsService.initializeDashboard();
    } catch (e) {
      // Log do erro mas não falha a operação principal
      log('Erro ao atualizar dashboard: ${e.toString()}');
    }
  }
}
