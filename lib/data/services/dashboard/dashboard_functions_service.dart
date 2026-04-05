import 'dart:developer';

import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firebase_functions_type_enum.dart';
import 'package:versystems_app/data/services/firebase_functions/firebase_functions_service.dart';

/// Interface para o serviço de funções do dashboard
abstract class DashboardFunctionsService {
  /// Inicializa o dashboard com dados existentes
  Future<Either<ServiceException, Unit>> initializeDashboard();
}

/// Implementação do serviço de funções do dashboard
class DashboardFunctionsServiceImpl implements DashboardFunctionsService {
  final FirebaseFunctionsService _firebaseFunctionsService;

  DashboardFunctionsServiceImpl({
    required FirebaseFunctionsService firebaseFunctionsService,
  }) : _firebaseFunctionsService = firebaseFunctionsService;

  @override
  Future<Either<ServiceException, Unit>> initializeDashboard() async {
    try {
      final result = await _firebaseFunctionsService.callFunctionVoid(
        functionType: FirebaseFunctionTypeEnum.initializeDashboard,
        data: {},
      );

      return result.fold(
        (ServiceException exception) {
          log('Erro ao inicializar dashboard: ${exception.message}');
          return Left(exception);
        },
        (Unit unit) => Right(unit),
      );
    } catch (e) {
      return Left(
        ServiceException(
          message: 'Erro ao inicializar dashboard: ${e.toString()}',
        ),
      );
    }
  }
}
