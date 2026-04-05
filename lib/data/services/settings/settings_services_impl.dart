import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

import 'settings_services.dart';

class SettingsServicesImpl implements SettingsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<Either<ServiceException, Map<String, dynamic>>> findSettings() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> result = await _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.settings)
          .doc('main')
          .get();
      final data = result.data();
      if (result.exists && data != null) {
        return Right(data);
      } else {
        return Left(ServiceException(message: 'Configurações do sistema não encontradas'));
      }
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  Future<Either<ServiceException, Map<String, dynamic>>> createMenuItems() async {
    try {
      final menuSchema = {
        "menu_schema": {
          "items": [
            {
              "icon": "dashboard",
              "initiallyExpanded": false,
              "level": 1000,
              "name": "Dashboard",
              "route": "/dashboard",
              "subItems": [],
            },
            {
              "icon": "format_list_bulleted",
              "initiallyExpanded": false,
              "level": 1000,
              "name": "Gestão de formulários",
              "route": "/formularies",
              "subItems": [],
            },
            {
              "icon": "editor_choice",
              "initiallyExpanded": false,
              "level": 1000,
              "name": "Gestão de Atividades",
              "route": "/activities",
              "subItems": [],
            },
            {
              "icon": "fact_check",
              "initiallyExpanded": false,
              "level": 1000,
              "name": "Minhas Tarefas",
              "route": "/tasks",
              "subItems": [],
            },
            {
              "icon": "checkbook",
              "initiallyExpanded": false,
              "level": 1000,
              "name": "Cadastros",
              "route": "/registrations",
              "subItems": [
                {
                  "icon": "business_center",
                  "initiallyExpanded": false,
                  "level": 1000,
                  "name": "Minhas Empresas",
                  "route": "/companies",
                  "subItems": [],
                },
                {
                  "icon": "support_agent",
                  "initiallyExpanded": false,
                  "level": 1000,
                  "name": "Clientes",
                  "route": "/clients",
                  "subItems": [],
                },
                {
                  "icon": "group",
                  "initiallyExpanded": false,
                  "level": 1000,
                  "name": "Usuários",
                  "route": "/users",
                  "subItems": [],
                },
                {
                  "icon": "category_search",
                  "initiallyExpanded": false,
                  "level": 1000,
                  "name": "Departamentos",
                  "route": "/departments",
                  "subItems": [],
                },
                {
                  "icon": "badge",
                  "initiallyExpanded": false,
                  "level": 1000,
                  "name": "Perfis",
                  "route": "/profiles",
                  "subItems": [],
                },
              ],
            },
          ],
        },
      };
      final docRef = _firestore
          .collection(FirestoreCollectionsHelper.branches)
          .doc(AppSessionController.instance.companyId)
          .collection(FirestoreCollectionsHelper.settings)
          .doc('main');

      await docRef.set(menuSchema);
      return Right({"message": "Menu created successfully"});
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }
}
