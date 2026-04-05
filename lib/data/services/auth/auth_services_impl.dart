import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

import 'auth_services.dart';

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<ServiceException, Unit>> logout() async {
    try {
      await _auth.signOut();
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, UserCredential?>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Right(userCredential);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }
}
