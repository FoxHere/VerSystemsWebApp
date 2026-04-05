

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';

abstract interface class FormularyRepository {
  Future<Either<RepositoryException, List<FormularyModel?>>> findAllFormularies();
  Future<Either<RepositoryException, String>> saveFormulary(FormularyModel formularyModel);
}
