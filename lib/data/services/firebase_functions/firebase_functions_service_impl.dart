import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firebase_functions_type_enum.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_functions_exception_helper.dart';

import 'firebase_functions_service.dart';

/// Implementação do serviço de Firebase Functions
///
/// Esta implementação utiliza o Firebase Functions para executar funções
/// serverless de forma segura e padronizada.
class FirebaseFunctionsServiceImpl implements FirebaseFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  FirebaseFunctionsServiceImpl();

  String get _companyId => AppSessionController.instance.companyId;

  @override
  Future<Either<ServiceException, T>> callFunction<T>({
    required FirebaseFunctionTypeEnum functionType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Verifica se a função está disponível
      if (!isFunctionAvailable(functionType)) {
        return Left(
          ServiceException(
            message: 'Função ${functionType.functionName} não está disponível',
          ),
        );
      }

      // Cria a referência para a função
      final HttpsCallable callable = _functions.httpsCallable(
        functionType.functionName,
      );

      // Executa a função
      final HttpsCallableResult result = await callable.call({
        "companyId": _companyId,
        ...data,
      });

      // Retorna o resultado tipado
      return Right(result.data as T);
    } on FirebaseFunctionsException catch (e) {
      return Left(
        ServiceException(
          message: HandleFbFunctionsExceptionHelper.handleFirebaseFunctionsException(e),
        ),
      );
    } on SocketException catch (_) {
      return Left(
        ServiceException(
          message: 'Sem conexão com a internet. Verifique sua conexão.',
        ),
      );
    } catch (e) {
      return Left(
        ServiceException(
          message: 'Erro desconhecido ao executar função ${functionType.functionName}: $e',
        ),
      );
    }
  }

  @override
  Future<Either<ServiceException, Unit>> callFunctionVoid({
    required FirebaseFunctionTypeEnum functionType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Verifica se a função está disponível
      if (!isFunctionAvailable(functionType)) {
        return Left(
          ServiceException(
            message: 'Função ${functionType.functionName} não está disponível',
          ),
        );
      }

      // Cria a referência para a função
      final HttpsCallable callable = _functions.httpsCallable(
        functionType.functionName,
      );

      // Executa a função
      await callable.call({
        "companyId": _companyId,
        ...data,
      });

      return Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(
        ServiceException(
          message: HandleFbFunctionsExceptionHelper.handleFirebaseFunctionsException(e),
        ),
      );
    } on SocketException catch (_) {
      return Left(
        ServiceException(
          message: 'Sem conexão com a internet. Verifique sua conexão.',
        ),
      );
    } catch (e) {
      return Left(
        ServiceException(
          message: 'Erro desconhecido ao executar função ${functionType.functionName}: $e',
        ),
      );
    }
  }

  @override
  bool isFunctionAvailable(FirebaseFunctionTypeEnum functionType) {
    // Por enquanto, todas as funções definidas no enum são consideradas disponíveis
    // Em uma implementação mais robusta, você poderia verificar se a função
    // realmente existe no Firebase Functions
    return FirebaseFunctionTypeEnum.values.contains(functionType);
  }

  @override
  List<FirebaseFunctionTypeEnum> getAvailableFunctions() {
    return FirebaseFunctionTypeEnum.values.where(isFunctionAvailable).toList();
  }
}
