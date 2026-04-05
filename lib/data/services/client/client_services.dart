import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

class ClientServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection(FirestoreCollectionsHelper.clients).doc(id).get();

      if (!snapshot.exists || snapshot.data() == null) {
        return Left(ServiceException(message: 'Cliente não encontrado'));
      }
      final data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;

      return Right(data);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido: $e'));
    }
  }

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({Map<String, dynamic>? filters}) async {
    try {
      // --------------------------------------------------------------- Query
      Query query = _firestore.collection(FirestoreCollectionsHelper.clients).orderBy('createdAt', descending: true);

      // --------------------------------------------------------------- filters
      if (filters?['companyId'] != null) {
        query = query.where('companyId', isEqualTo: filters?['companyId']);
      }

      if (filters?['name'] != null) {
        query = query.where('name', isGreaterThanOrEqualTo: filters?['name']).where('name', isLessThan: '${filters?['name']}z');
      }

      // --------------------------------------------------------------- Snapshot
      QuerySnapshot snapshot = await query.get();
      final result = snapshot.docs.where((doc) => doc.data() != null).map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        data['id'] = doc.id;
        return data;
      }).toList();

      return Right(result);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido: $e'));
    }
  }

  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> clientMap) async {
    try {
      String docRef = '';

      if (clientMap['id'] == null) {
        docRef = await _firestore.collection(FirestoreCollectionsHelper.clients).add(clientMap).then((client) => client.id);
      } else {
        await _firestore.collection(FirestoreCollectionsHelper.clients).doc(clientMap['id']).set(clientMap, SetOptions(merge: true));
      }
      final newId = docRef.isNotEmpty ? docRef : clientMap['id'];

      return Right(newId);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido: $e'));
    }
  }

  Future<Either<ServiceException, Unit>> update(Map<String, dynamic> clientMap) async {
    try {
      await _firestore.collection(FirestoreCollectionsHelper.clients).doc(clientMap['id']).set(clientMap, SetOptions(merge: true));

      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido: $e'));
    }
  }

  Future<Either<ServiceException, Unit>> delete(String id) async {
    try {
      await _firestore.collection(FirestoreCollectionsHelper.clients).doc(id).delete();

      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido: $e'));
    }
  }
}
