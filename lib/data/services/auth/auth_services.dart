import 'package:firebase_auth/firebase_auth.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';

abstract interface class AuthService {
  Future<Either<ServiceException, UserCredential?>> signIn({required String email, required String password});
  Future<Either<ServiceException, Unit>> logout();
}
