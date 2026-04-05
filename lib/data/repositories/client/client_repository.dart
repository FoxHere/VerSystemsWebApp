

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/config/fp/unit.dart';

abstract interface class ClientRepository {
  Future<Either<RepositoryException, ClientModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<ClientModel>>> findAllClients(
    Map<String, dynamic> filters,
  );
  Future<Either<RepositoryException, String>> saveClient(ClientModel clientModel);
  Future<Either<RepositoryException, Unit>> updateClient(ClientModel clientModel);
  Future<Either<RepositoryException, Unit>> deleteClient(String id);
}
