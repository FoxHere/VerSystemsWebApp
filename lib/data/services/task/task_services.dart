import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

class TaskServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /*
   Essa é uma função temporária para buscar a estrutura do 
   formulário no firebase usando um arquivo json
   */
  Future<Either<ServiceException, Map<String, dynamic>>> findOneById(String id) async {
    try {
      final DocumentSnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.activities)
          .doc(id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(ServiceException(message: 'Documento não encontrado'));
      }
      return Right(snapshot.data() as Map<String, dynamic>);
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
      Query query = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.tasks)
          .orderBy('createdAt', descending: true);
      // --------------------------------------------------------------- filters
      if (filters?['userId'] != null) {
        query = query.where('.id', isEqualTo: filters?['userId']);
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
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, Unit>> onSave(Map<String, dynamic> taskMap) async {
    try {
      await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.tasks)
          .doc(taskMap['id'])
          .set(taskMap, SetOptions(merge: true));

      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, Map<String, dynamic>>> loadJson() async {
    String jsonString = await rootBundle.loadString('assets/files/form_exec_file_test.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return Right(jsonData);
  }
}
