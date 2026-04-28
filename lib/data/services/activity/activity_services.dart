import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

class ActivityServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.activities)
          .doc(id)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        return Left(ServiceException(message: 'Atividade não encontrada'));
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
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findOneByFormulary(String formularyId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.activities)
          .where('formulary.id', isEqualTo: formularyId)
          .get();

      final activities = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      return Right(activities);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({Map<String, dynamic>? filters}) async {
    try {
      // --------------------------------------------------------------- Query
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.activities);

      // --------------------------------------------------------------- filters
      if (filters?['userId'] != null) {
        query = query.where('responsible.id', isEqualTo: filters?['userId']);
      }
      // --------------------------------------------------------------- Order
      query = query.orderBy('createdAt', descending: true);

      // --------------------------------------------------------------- Snapshot
      QuerySnapshot snapshot = await query.get();

      final result = snapshot.docs.where((doc) => doc.data() != null).map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        data['id'] = doc.id;
        return data;
      }).toList();

      return Right(result);
    } on FirebaseException catch (e) {
      log('FirebaseException code: ${e.code}');
      log('FirebaseException message: ${e.message}');
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> activityMap) async {
    try {
      String docRef = '';

      if (activityMap['id'] == null) {
        docRef = await _firestore
            .collection(FirestoreCollectionsHelper.branches)
            .doc(AppSessionController.instance.companyId)
            .collection(FirestoreCollectionsHelper.activities)
            .add(activityMap)
            .then((activity) => activity.id);
      } else {
        await _firestore
            .collection(FirestoreCollectionsHelper.branches)
            .doc(AppSessionController.instance.companyId)
            .collection(FirestoreCollectionsHelper.activities)
            .doc(activityMap['id'])
            .set(activityMap, SetOptions(merge: true));
      }
      final newId = docRef.isNotEmpty ? docRef : activityMap['id'];

      return Right(newId);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, Unit>> delete(String id) async {
    try {
      await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.activities)
          .doc(id)
          .delete();

      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, Unit>> updateActivityStatus(Map<String, dynamic> activity) async {
    try {
      await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.activities)
          .doc(activity['id'])
          .update({'status': activity['status']});

      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido: $e'));
    }
  }
}
