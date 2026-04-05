import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';
import 'package:versystems_app/data/services/user/user_services.dart';


class UserServicesImpl implements UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findOneByDepartment(
    String departmentId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.users)
          .where('department', isEqualTo: departmentId)
          .get();

      final users = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      return Right(users);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(
        ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'),
      );
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findByProfile(
    String profileId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.users)
          .where('profile', isEqualTo: profileId)
          .get();

      final users = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      return Right(users);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(
        ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'),
      );
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id) async {
    try {
      final DocumentSnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.users)
          .doc(id)
          .get();
      final data = snapshot.data() as Map<String, dynamic>;
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(ServiceException(message: 'Usuário não encontrado'));
      }
      data['id'] = snapshot.id;
      return Right(data);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(
        ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'),
      );
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({
    Map<String, dynamic>? filters,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.users)
          .orderBy('createdAt', descending: true)
          .get();

      final result = snapshot.docs.where((doc) => doc.data() != null).map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        data['id'] = doc.id;
        return data;
      }).toList();
      if (result.isEmpty) {
        return Right([]); // Lista vazia explícita
      }
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> userMap) async {
    try {
      String docRef = '';
      if (userMap['id'] == null) {
        docRef = await _firestore
            .collection(FirestoreCollectionsHelper.users)
            .add(userMap)
            .then((user) => user.id);
      } else {
        await _firestore
            .collection(FirestoreCollectionsHelper.users)
            .doc(userMap['id'])
            .set(userMap, SetOptions(merge: true));
      }

      final newId = docRef.isNotEmpty ? docRef : userMap['id'];
      return Right(newId);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, String?>> findImgProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final ref = await _storage
          .ref()
          .child('user_photo/${currentUser!.uid}/profile.webp')
          .getDownloadURL();
      return Right(ref);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, String>> uploadImgProfile(String imagePath) async {
    try {
      File file = File(imagePath);
      final uid = FirebaseAuth.instance.currentUser;
      final ref = _storage.ref().child('user_images/$uid/profile.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL().then((value) => Right(value));
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(
        ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'),
      );
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, Unit>> delete(String id) async {
    try {
      await _firestore.collection(FirestoreCollectionsHelper.users).doc(id).delete();

      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }
}
