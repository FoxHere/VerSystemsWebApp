import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';


class FormularyServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.formularies)
          .doc(id)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        return Left(ServiceException(message: 'Formulário não encontrado'));
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

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({
    Map<String, dynamic>? filters,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.formularies)
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
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, String>> onSave(Map<String, dynamic> formularyMap) async {
    try {
      String docRef = '';
      if (formularyMap['id'] == null) {
        docRef = await _firestore
            .collection(FirestoreCollectionsHelper.branches)
            .doc(AppSessionController.instance.companyId)
            .collection(FirestoreCollectionsHelper.formularies)
            .add(formularyMap)
            .then((value) => value.id);
      } else {
        await _firestore
            .collection(FirestoreCollectionsHelper.branches)
            .doc(AppSessionController.instance.companyId)
            .collection(FirestoreCollectionsHelper.formularies)
            .doc(formularyMap['id'])
            .set(formularyMap, SetOptions(merge: true));
      }
      final newId = docRef.isNotEmpty ? docRef : formularyMap['id'];
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
          .collection(FirestoreCollectionsHelper.formularies)
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

  Future<Either<ServiceException, int>> findReponseCount(String id) async {
    try {
      AggregateQuerySnapshot formResponsesCount = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.formularies)
          .doc(id)
          .collection(FirestoreCollectionsHelper.responses)
          .count()
          .get();
      return Right(formResponsesCount.count ?? 0);
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }
}
