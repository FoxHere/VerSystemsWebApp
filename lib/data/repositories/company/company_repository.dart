

import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/company/company_model.dart';

abstract interface class CompanyRepository {
  Future<Either<RepositoryException, CompanyModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<CompanyModel>>> findAllCompanies(
    Map<String, dynamic> filters,
  );
  Future<Either<RepositoryException, String>> saveCompany(CompanyModel companyModel);
  Future<Either<RepositoryException, Unit>> updateCompany(CompanyModel companyModel);
  Future<Either<RepositoryException, Unit>> deleteCompany(String id);
  Future<Either<RepositoryException, bool>> hasAnyCompany();
  /// Gera um ID único para empresa baseado no [Env.companyId] + sufixo a-z.
  Future<Either<RepositoryException, String>> generateCompanyId();
}
