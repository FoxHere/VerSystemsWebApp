import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

class DashboardServicesImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<ServiceException, Map<String, dynamic>>> findOne(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.dashboard)
          .doc(id)
          .get();
      final data = result.data();
      if (result.exists && data != null) {
        data['id'] = result.id;
        return Right(data);
      } else {
        return Left(ServiceException(message: 'Dashboard não encontrado'));
      }
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, List<Map<String, dynamic>>>> findAll({Map<String, dynamic>? filters}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.dashboard)
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
}
