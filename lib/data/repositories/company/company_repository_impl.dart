import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/utils/env.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/repositories/company/company_repository.dart';
import 'package:versystems_app/data/services/company/company_services.dart';

const _dashboardInitialData = {
  'formularies': {'profile': 1000, 'total': 0, 'total_this_month': 0},
  'activities': {'profile': 1000, 'total': 0, 'total_this_month': 0},
  'pendentTasks': {'profile': 0, 'users': {}},
  'members': {'profile': 1000, 'total': 0, 'total_this_month': 0},
};

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyServices _companyServices;

  CompanyRepositoryImpl({required CompanyServices companyServices})
    : _companyServices = companyServices;

  @override
  Future<Either<RepositoryException, CompanyModel?>> findOneById(String id) async {
    try {
      final result = await _companyServices.findOne(id);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (Map<String, dynamic> companyMap) {
          if (companyMap.isEmpty) return Right(null);
          final companyModel = CompanyModel.fromJson(companyMap);
          return Right(companyModel);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, List<CompanyModel>>> findAllCompanies(Map<String, dynamic> filters) async {
    try {
      final result = await _companyServices.findAll(filters: filters);
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> companies) {
          if (companies.isEmpty) return Right(<CompanyModel>[]);
          final companyModelList = companies.map((companyMap) => CompanyModel.fromJson(companyMap)).toList();
          return Right(companyModelList);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, String>> saveCompany(CompanyModel companyModel) async {
    try {
      // Se não há ID (primeiro setup), gera um baseado no Env.companyId
      String? resolvedId = companyModel.id.isNotEmpty ? companyModel.id : null;
      if (resolvedId == null) {
        final idResult = await generateCompanyId();
        final idError = idResult.fold(
          (RepositoryException e) {
            return e.message;
          },
          (String id) {
            resolvedId = id;
            return null;
          },
        );
        if (idError != null) {
          return Left(RepositoryException(message: idError));
        }
      }

      final isNewCompany = companyModel.id.isEmpty;
      final companyWithId = companyModel.copyWith(id: resolvedId);
      final companyMap = companyWithId.toJsonForFirebase();
      final result = await _companyServices.onSave(companyMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao salvar empresa: ${se.message}'));
        },
        (String savedCompanyId) async {
          // Inicializa o dashboard da empresa recém-criada
          if (isNewCompany) {
            await _initializeDashboard(savedCompanyId);
          }
          return Right(savedCompanyId);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao salvar empresa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> updateCompany(CompanyModel companyModel) async {
    try {
      final companyMap = companyModel.toJsonForFirebase();
      final result = await _companyServices.update(companyMap);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao atualizar empresa: ${se.message}'));
        },
        (Unit unit) async {
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao atualizar empresa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteCompany(String id) async {
    try {
      final result = await _companyServices.delete(id);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao deletar empresa: ${se.message}'));
        },
        (Unit unit) async {
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao deletar empresa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> hasAnyCompany() async {
    try {
      final result = await _companyServices.findAll(filters: {'limit': 1});
      return result.fold(
        (ServiceException exception) {
          return Left(RepositoryException(message: exception.message));
        },
        (List<Map<String, dynamic>> companies) {
          return Right(companies.isNotEmpty);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro ao verificar empresas: ${e.toString()}'));
    }
  }

  /// Gera um ID único para a empresa no formato:
  ///   [Env.companyId] + sufixo de letra (a, b, c, ... z)
  ///
  /// Tenta cada candidato em ordem até encontrar um documento inexistente
  /// no Firestore. Garante unicidade mesmo em ambientes multi-instância.
  @override
  Future<Either<RepositoryException, String>> generateCompanyId() async {
    try {
      final base = Env.companyId.isNotEmpty ? Env.companyId : 'company';
      final firestore = FirebaseFirestore.instance;
      const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

      for (final letter in alphabet.split('')) {
        final candidate = '$base$letter';
        final doc = await firestore.collection(FirestoreCollectionsHelper.branches).doc(candidate).get();
        if (!doc.exists) {
          return Right(candidate);
        }
      }

      // Caso raros: todas as 26 letras já foram usadas (26 filiais)
      return Left(
        RepositoryException(
          message:
              'Não foi possível gerar um ID único para a empresa. '
              'Limite de 26 filiais com o prefixo "$base" atingido.',
        ),
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro ao gerar ID de empresa: ${e.toString()}'));
    }
  }

  /// Cria o documento `dashboard/main` dentro da branch recém-criada
  /// com dados zerados. Usa [SetOptions.merge] para não sobrescrever
  /// um dashboard que por algum motivo já exista.
  Future<void> _initializeDashboard(String companyId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final dashboardRef = firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(companyId)
          .collection(FirestoreCollectionsHelper.dashboard)
          .doc('main');
      await dashboardRef.set(_dashboardInitialData, SetOptions(merge: true));
    } catch (e) {
      // Não bloqueia o fluxo principal — loga o erro mas ignora
      // O dashboard será criado pelas Cloud Functions quando houver atividade
      // ignore: avoid_print
      print('[CompanyRepository] Erro ao inicializar dashboard: $e');
    }
  }
}
