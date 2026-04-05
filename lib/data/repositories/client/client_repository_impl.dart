

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/repositories/client/client_repository.dart';
import 'package:versystems_app/data/services/client/client_services.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientServices _clientServices;

  ClientRepositoryImpl({
    required ClientServices clientServices,
  }) : _clientServices = clientServices;

  @override
  Future<Either<RepositoryException, ClientModel?>> findOneById(String id) async {
    try {
      final result = await _clientServices.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> clientMap) {
          if (clientMap.isEmpty) return Right(null);
          final clientModel = ClientModel.fromJson(clientMap);
          return Right(clientModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ClientModel>>> findAllClients(
    Map<String, dynamic> filters,
  ) async {
    try {
      final result = await _clientServices.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> clients) {
          if (clients.isEmpty) return Right(<ClientModel>[]);
          final clientModelList = clients
              .map((clientMap) => ClientModel.fromJson(clientMap))
              .toList();
          return Right(clientModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, String>> saveClient(ClientModel clientModel) async {
    try {
      final clientMap = clientModel.toJsonForFirebase();
      if (clientModel.id.isEmpty) clientMap.remove('id');
      final result = await _clientServices.onSave(clientMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao salvar cliente: ${se.message}'));
        },
        (String clientId) async {
          return Right(clientId);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao salvar cliente: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> updateClient(ClientModel clientModel) async {
    try {
      final clientMap = clientModel.toJsonForFirebase();
      final result = await _clientServices.update(clientMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao atualizar cliente: ${se.message}'));
        },
        (Unit unit) async {
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao atualizar cliente: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteClient(String id) async {
    try {
      final result = await _clientServices.delete(id);
      return result.fold(
        (ServiceException se) async {
          return Left(
            RepositoryException(message: 'Erro ao deletar cliente: ${se.message}'),
          );
        },
        (Unit unit) async {
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(
        RepositoryException(message: 'Erro no repositório ao deletar cliente: ${e.toString()}'),
      );
    }
  }
}
