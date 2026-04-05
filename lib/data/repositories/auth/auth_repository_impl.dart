import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/services/auth/auth_services_impl.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import './auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthServiceImpl _authServiceImpl;
  final UserServicesImpl _userServicesImpl;
  final DepartmentServicesImpl _departmentServicesImpl;
  final ProfileServicesImpl _profileServivesImpl;
  final _securityStorage = const FlutterSecureStorage();
  AuthRepositoryImpl({
    required AuthServiceImpl authServiceImp,
    required UserServicesImpl userServicesImpl,
    required DepartmentServicesImpl departmentServicesImpl,
    required ProfileServicesImpl profileServivesImpl,
  }) : _authServiceImpl = authServiceImp,
       _userServicesImpl = userServicesImpl,
       _departmentServicesImpl = departmentServicesImpl,
       _profileServivesImpl = profileServivesImpl;

  final userModel = Rx<UserModel?>(null);

  @override
  Future<Either<RepositoryException, bool>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await _authServiceImpl.signIn(email: email, password: password);

      return await userCredentials.fold(
        (exception) => Left(RepositoryException(message: exception.message)),
        (credentials) async {
          final uid = credentials?.user?.uid;
          if (uid == null) {
            return Left(RepositoryException(message: 'Usuário ou senha inválidos'));
          }

          final userResult = await _userServicesImpl.findOne(uid);

          return await userResult.fold(
            (userError) => Left(RepositoryException(message: userError.message)),
            (userData) async {
              var departmentId = userData['department'];
              var profileId = userData['profile'];

              if (departmentId is Map) departmentId = departmentId['id'];
              if (profileId is Map) profileId = profileId['id'];

              if (departmentId == null || profileId == null) {
                return Left(RepositoryException(message: 'Usuário sem perfil ou departamento.'));
              }

              // Define o companyId na sessão ANTES de chamar services
              // que dependem dele (department e profile).
              final company = userData['company'] as String? ?? '';
              if (company.isNotEmpty) {
                AppSessionController.instance.setCompanyId(company);
              }

              final deptResult = await _departmentServicesImpl.findOne(departmentId);
              final profileResult = await _profileServivesImpl.findOne(profileId);

              return await deptResult.fold(
                (deptError) => Left(RepositoryException(message: deptError.message)),
                (deptDoc) async {
                  return await profileResult.fold(
                    (profileError) => Left(RepositoryException(message: profileError.message)),
                    (profileDoc) async {
                      if (deptDoc.isEmpty || profileDoc.isEmpty) {
                        return Left(
                          RepositoryException(
                            message: 'Dados de perfil ou departamento inválidos.',
                          ),
                        );
                      }

                      final departmentData = deptDoc;
                      final profileData = profileDoc;

                      userModel.value = UserModel.fromFirebase(
                        id: uid,
                        userData: userData,
                        departmentData: departmentData,
                        profileData: profileData,
                      );
                      final userJson = userModel.value?.toJson();
                      final userString = jsonEncode(userJson);
                      debugPrint(userString);
                      await _securityStorage.write(key: 'udata', value: userString);
                      // isAuthenticated.value = true;
                      return Right(true);
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      return Left(RepositoryException(message: 'Erro inesperado: $e'));
    }
  }

  Future<void> logout() async {
    await _authServiceImpl.logout();
    userModel.value = null;
    await _securityStorage.delete(key: 'udata');
    AppSessionController.instance.clearSession();
  }
}
