import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firebase_functions_type_enum.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/repositories/user/user_repository.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/firebase_functions/firebase_functions_service_impl.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserServicesImpl _userServices;
  final ProfileServicesImpl _profileServices;
  final DepartmentServicesImpl _departmentServices;
  final ImageServices _imageServices;
  final FirebaseFunctionsServiceImpl _firebaseFunctionsServices;
  final DashboardFunctionsService _dashboardFunctionsService;

  UserRepositoryImpl({
    required UserServicesImpl userServicesImpl,
    required ProfileServicesImpl profileServicesImpl,
    required DepartmentServicesImpl departmentServicesImpl,
    required ImageServices imageServices,
    required FirebaseFunctionsServiceImpl firebaseFunctionsServicesImpl,
    required DashboardFunctionsService dashboardFunctionsService,
  }) : _userServices = userServicesImpl,
       _profileServices = profileServicesImpl,
       _departmentServices = departmentServicesImpl,
       _imageServices = imageServices,
       _firebaseFunctionsServices = firebaseFunctionsServicesImpl,
       _dashboardFunctionsService = dashboardFunctionsService;

  final _securyStorage = const FlutterSecureStorage();

  @override
  Future<Either<RepositoryException, UserModel?>> findOneById(String id) async {
    final user = await _userServices.findOne(id);

    return await user.fold(
      (se) {
        return Left(RepositoryException(message: se.message));
      },
      (Map<String, dynamic> userData) async {
        var departmentId = userData['departmentId'] ?? userData['department'];
        var profileId = userData['profile'];

        if (departmentId is Map) departmentId = departmentId['id'];
        if (profileId is Map) profileId = profileId['id'];

        if (departmentId == null || profileId == null) {
          return Left(RepositoryException(message: 'Usuário sem departamento ou perfil'));
        }

        final department = await _departmentServices.findOne(departmentId);
        final profile = await _profileServices.findOne(profileId);

        return department.fold(
          (ServiceException departmentException) => Left(RepositoryException(message: departmentException.message)),
          (Map<String, dynamic> department) => profile.fold(
            (ServiceException profileError) => Left(RepositoryException(message: profileError.message)),
            (Map<String, dynamic> profile) =>
                Right(UserModel.fromFirebase(id: userData['id'], userData: userData, departmentData: department, profileData: profile)),
          ),
        );
      },
    );
  }

  @override
  Future<Either<RepositoryException, List<UserModel>>> findAllUsers(Map<String, dynamic> filters) async {
    final result = await _userServices.findAll();
    return await result.fold((l) => Left(RepositoryException(message: l.message)), (List<Map<String, dynamic>> usersMap) async {
      try {
        if (usersMap.isEmpty) return Right([]);

        final userModelList = await Future.wait(
          usersMap.map((Map<String, dynamic> userMap) async {
            var departmentId = userMap['department'] ?? userMap['departmentId'];
            var profileId = userMap['profile'];

            if (departmentId is Map) departmentId = departmentId['id'];
            if (profileId is Map) profileId = profileId['id'];

            if (departmentId == null || profileId == null) {
              throw RepositoryException(message: 'Usuário sem departamento ou perfil');
            }
            final department = await _departmentServices.findOne(departmentId);
            final profile = await _profileServices.findOne(profileId);

            return department.fold(
              (l) => throw RepositoryException(message: l.message),
              (Map<String, dynamic> department) => profile.fold((l) => throw RepositoryException(message: l.message), (Map<String, dynamic> profile) {
                return UserModel.fromFirebase(id: userMap['id'], userData: userMap, departmentData: department, profileData: profile);
              }),
            );
          }).toList(),
        );
        return Right(userModelList);
      } catch (e) {
        return Left(RepositoryException(message: 'Erro no repositório ao tratar formulários ${e.toString()}'));
      }
    });
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteUser(String id) async {
    try {
      final deleteAuth = await _firebaseFunctionsServices.callFunction<Map<String, dynamic>>(
        functionType: FirebaseFunctionTypeEnum.deleteAuthUser,
        data: {'uid': id},
      );
      if (deleteAuth.isLeft()) {
        return Left(RepositoryException(message: 'Erro ao deletar o usuário'));
      }
      final result = await _userServices.delete(id);
      return result.fold(
        (ServiceException se) async {
          return Left(RepositoryException(message: 'Erro ao deletar o perfil: ${se.message}'));
        },
        (Unit unit) async {
          // Atualiza o dashboard após deletar usuário
          await _updateDashboard();
          return Right(unit);
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao deletar o perfil ${e.toString()}'));
    }
  }

  Future<UserModel?> loadUserDataFromSecurityStorage() async {
    final jsonString = await _securyStorage.read(key: 'udata');
    if (jsonString != null) {
      final userMap = jsonDecode(jsonString);
      final userModel = UserModel.fromJson(userMap);
      return userModel;
    } else {
      await _securyStorage.delete(key: 'udata');
      return null;
    }
  }

  Future<void> saveUserDataToSecurityStorage(UserModel userModel) async {
    final jsonString = jsonEncode(userModel.toJson());
    await _securyStorage.write(key: 'udata', value: jsonString);
    return;
  }

  @override
  Future<Either<RepositoryException, UserModel>> saveUser({required UserModel userModel, bool isFirstUser = false}) async {
    try {
      final isNew = userModel.id.isEmpty;
      // criar uma função no perfil para verificar se é admin (talvez uma chave para isso)
      final isAdmin = userModel.profile.level >= 1000 && userModel.profile.name.toLowerCase().contains("administrador") || isFirstUser;

      /// Alterar para verificar se é admin e fazer a criação de usuário;
      final authUserPayload = {
        'email': userModel.email,
        'password': 'Mudar@123',
        'displayName': userModel.name,
        'customClaims': {'admin': isAdmin},
      };

      String? uid = userModel.id;
      if (isNew) {
        /// 1. Criar usuário no Firebase Auth --------------------------------------------------------------
        final createAuth = await _firebaseFunctionsServices.callFunction<Map<String, dynamic>>(
          functionType: FirebaseFunctionTypeEnum.createAuthUser,
          data: {'userModel': authUserPayload, 'isFirstUser': isFirstUser},
        );
        if (createAuth.isLeft()) {
          return Left(RepositoryException(message: createAuth.getLeftOrThrow().message));
        }
        final data = createAuth.getOrElse(() => const {});
        uid = (data['uid'] as String?) ?? '';

        if (uid.isEmpty) {
          return Left(RepositoryException(message: 'Erro ao criar usuário no Firebase Auth'));
        }
        userModel = userModel.copyWith(id: uid);
      }

      /// 2. Upload da imagem do perfil --------------------------------------------------------------
      if (userModel.profileImage?.bytes != null && userModel.profileImage?.bytes.isNotEmpty == true) {
        final ImageItemModel imageModel = userModel.profileImage!;
        final uploadResult = await uploadImage(imageModel, userModel.id);
        if (uploadResult.isLeft()) {
          if (isNew) {
            await _firebaseFunctionsServices.callFunction(functionType: FirebaseFunctionTypeEnum.deleteAuthUser, data: {'uid': uid});
          }
          return Left(RepositoryException(message: uploadResult.getLeftOrThrow().message));
        }

        final imageUrl = uploadResult.getOrElse(() => ImageItemModel(bytes: Uint8List(0), name: '', sizeBytes: 0, downloadUrl: '')).downloadUrl;
        userModel = userModel.copyWith(profileImage: imageModel.copyWith(downloadUrl: imageUrl));
      }

      /// 3. Salvar dados do usuário no Firebase ------------------------------------------------------
      final userMap = userModel.toJsonForFirebase();
      // if (userModel.id.isEmpty) userMap.remove('id');
      final result = await _userServices.onSave(userMap);
      return result.fold(
        (ServiceException se) async {
          if (isNew) {
            await _firebaseFunctionsServices.callFunction(functionType: FirebaseFunctionTypeEnum.deleteAuthUser, data: {'uid': uid});
          }
          return Left(RepositoryException(message: 'Erro ao salvar o usuário: ${se.message}'));
        },
        (String userId) async {
          // Atualiza o dashboard após salvar usuário
          await _updateDashboard();
          return Right(userModel.copyWith(id: userId));
        },
      );
    } catch (e) {
      return Left(RepositoryException(message: 'Erro no repositório ao tratar o usuário ${e.toString()}'));
    }
  }

  Future<Either<RepositoryException, ImageItemModel>> uploadImage(ImageItemModel image, String userId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('user_photo/$userId/profile.jpg');
      final uploadTask = ref.putData(image.bytes);
      final TaskSnapshot snapshot = await uploadTask;

      final FullMetadata metadata = await snapshot.ref.getMetadata();
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(
        ImageItemModel(
          bytes: Uint8List(0),
          downloadUrl: downloadUrl,
          fullPath: snapshot.ref.fullPath,
          name: snapshot.ref.name,
          sizeBytes: metadata.size!,
          bucket: metadata.bucket!,
        ),
      );
    } catch (e) {
      log('Erro no repositório ao subir imagem ${e.toString()}');
      return Left(RepositoryException(message: 'Erro no repositório ao subir imagem ${e.toString()}'));
    }
  }

  /// Atualiza o dashboard após mudanças nos usuários
  Future<void> _updateDashboard() async {
    try {
      await _dashboardFunctionsService.initializeDashboard();
    } catch (e) {
      // Log do erro mas não falha a operação principal
      log('Erro ao atualizar dashboard: ${e.toString()}');
    }
  }
}

class UploadResult {
  final String downloadUrl;
  final String fullPath;
  final String name;
  final int? sizeBytes;
  final String? contentType;
  final String bucket;

  UploadResult({required this.downloadUrl, required this.fullPath, required this.name, this.sizeBytes, this.contentType, required this.bucket});
}
