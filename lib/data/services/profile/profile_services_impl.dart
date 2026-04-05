import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';
import 'package:versystems_app/data/services/profile/profile_services.dart';


class ProfileServicesImpl implements ProfileServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result = await _firestore
          .collection(FirestoreCollectionsHelper.profiles)
          .doc(id)
          .get();
      final data = result.data();
      if (result.exists && data != null) {
        data['id'] = result.id;
        return Right(data);
      } else {
        return Left(ServiceException(message: 'Perfil não encontrado'));
      }
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
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
          .collection(FirestoreCollectionsHelper.profiles)
          .get();

      final result = snapshot.docs.where((doc) => doc.data() != null).map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        data['id'] = doc.id;
        return data;
      }).toList();

      if (result.isEmpty) return Right([]); // Lista vazia explícita
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  @override
  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> userMap) async {
    try {
      String docRef = '';
      if (userMap['id'] == null) {
        docRef = await _firestore
            .collection(FirestoreCollectionsHelper.profiles)
            .add(userMap)
            .then((profile) => profile.id);
      } else {
        await _firestore
            .collection(FirestoreCollectionsHelper.profiles)
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
  Future<Either<ServiceException, Unit>> delete(String id) async {
    try {
      await _firestore.collection(FirestoreCollectionsHelper.profiles).doc(id).delete();

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
