import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firebase_functions_type_enum.dart';

/// Interface abstrata para o serviço de Firebase Functions
///
/// Este service abstrai as chamadas para Firebase Functions, permitindo
/// que outros services utilizem as funções de forma padronizada e segura.
abstract interface class FirebaseFunctionsService {
  /// Executa uma função do Firebase Functions
  ///
  /// [functionType] - Tipo da função a ser executada (enum)
  /// [data] - Dados a serem enviados para a função
  ///
  /// Retorna [Either<ServiceException, T>] onde T é o tipo de retorno da função
  Future<Either<ServiceException, T>> callFunction<T>({
    required FirebaseFunctionTypeEnum functionType,
    required Map<String, dynamic> data,
  });

  /// Executa uma função do Firebase Functions sem retorno
  ///
  /// [functionType] - Tipo da função a ser executada (enum)
  /// [data] - Dados a serem enviados para a função
  ///
  /// Retorna [Either<ServiceException, Unit>] indicando sucesso ou falha
  Future<Either<ServiceException, Unit>> callFunctionVoid({
    required FirebaseFunctionTypeEnum functionType,
    required Map<String, dynamic> data,
  });

  /// Verifica se uma função está disponível
  ///
  /// [functionType] - Tipo da função a ser verificada
  ///
  /// Retorna true se a função estiver disponível, false caso contrário
  bool isFunctionAvailable(FirebaseFunctionTypeEnum functionType);

  /// Retorna lista de todas as funções disponíveis
  List<FirebaseFunctionTypeEnum> getAvailableFunctions();
}
