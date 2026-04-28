import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/helpers/firebase/date_normalization_helper.dart';
import 'package:versystems_app/config/helpers/firebase/firestore_collections_helper.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

class DevServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<ServiceException, Map<String, dynamic>>> createMenuItemsOnfirebase() async {
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
              "route": "/tasks",
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
      log(e.toString());
      return Left(ServiceException(message: 'Erro desconhecido erro: $e'));
    }
  }

  /// Normaliza todos os campos de data no Firebase, convertendo strings para Timestamp
  ///
  /// Este método percorre todas as coleções e normaliza os campos de data
  /// que estão salvos como string para Timestamp.
  ///
  /// Retorna um relatório com o número de documentos normalizados por coleção.
  Future<Either<ServiceException, Map<String, dynamic>>> normalizeAllDateFields() async {
    try {
      log('🚀 Iniciando normalização de campos de data...');

      final report = <String, int>{};
      int totalNormalized = 0;

      // 1. Normalizar coleção de usuários (raiz)
      final usersResult = await _normalizeCollection(
        collectionPath: FirestoreCollectionsHelper.users,
        dateFields: ['createdAt', 'updatedAt'],
      );
      report['users'] = usersResult;
      totalNormalized += usersResult;
      log('✅ Usuários normalizados: $usersResult');

      // 2. Normalizar coleção de departamentos (raiz)
      final departmentsResult = await _normalizeCollection(
        collectionPath: FirestoreCollectionsHelper.departments,
        dateFields: ['createdAt', 'updatedAt'],
      );
      report['departments'] = departmentsResult;
      totalNormalized += departmentsResult;
      log('✅ Departamentos normalizados: $departmentsResult');

      // 3. Normalizar coleção de perfis (raiz)
      final profilesResult = await _normalizeCollection(
        collectionPath: FirestoreCollectionsHelper.profiles,
        dateFields: ['createdAt', 'updatedAt'],
      );
      report['profiles'] = profilesResult;
      totalNormalized += profilesResult;
      log('✅ Perfis normalizados: $profilesResult');

      // 4. Normalizar coleção de empresas (branches - raiz)
      final companiesResult = await _normalizeCollection(
        collectionPath: FirestoreCollectionsHelper.branches,
        dateFields: ['createdAt', 'updatedAt'],
      );
      report['companies'] = companiesResult;
      totalNormalized += companiesResult;
      log('✅ Empresas normalizadas: $companiesResult');

      // 5. Normalizar subcoleções dentro de branches/{companyId}
      final branchesSnapshot = await _firestore.collection(FirestoreCollectionsHelper.branches).get();

      for (final branchDoc in branchesSnapshot.docs) {
        final companyId = branchDoc.id;
        log('📁 Processando empresa: $companyId');

        // 5.1. Formulários
        final formulariesResult = await _normalizeSubCollection(
          parentPath: '${FirestoreCollectionsHelper.branches}/$companyId',
          collectionName: FirestoreCollectionsHelper.formularies,
          dateFields: ['createdAt', 'updatedAt'],
        );
        report['formularies_$companyId'] = formulariesResult;
        totalNormalized += formulariesResult;
        log('  ✅ Formulários normalizados: $formulariesResult');

        // 5.2. Atividades (tem campos adicionais: startDateTime, endDateTime)
        final activitiesResult = await _normalizeSubCollection(
          parentPath: '${FirestoreCollectionsHelper.branches}/$companyId',
          collectionName: FirestoreCollectionsHelper.activities,
          dateFields: ['createdAt', 'updatedAt', 'startDateTime', 'endDateTime'],
          nestedDateFields: {
            'formulary': ['createdAt', 'updatedAt'],
            'responsible': ['createdAt', 'updatedAt'],
            'client': ['createdAt', 'updatedAt'],
          },
        );
        report['activities_$companyId'] = activitiesResult;
        totalNormalized += activitiesResult;
        log('  ✅ Atividades normalizadas: $activitiesResult');

        // 5.3. Tarefas (tasks)
        final tasksResult = await _normalizeSubCollection(
          parentPath: '${FirestoreCollectionsHelper.branches}/$companyId',
          collectionName: FirestoreCollectionsHelper.tasks,
          dateFields: ['createdAt', 'updatedAt', 'startDateTime', 'endDateTime'],
        );
        report['tasks_$companyId'] = tasksResult;
        totalNormalized += tasksResult;
        log('  ✅ Tarefas normalizadas: $tasksResult');

        // 5.4. Clientes
        final clientsResult = await _normalizeSubCollection(
          parentPath: '${FirestoreCollectionsHelper.branches}/$companyId',
          collectionName: FirestoreCollectionsHelper.clients,
          dateFields: ['createdAt', 'updatedAt'],
        );
        report['clients_$companyId'] = clientsResult;
        totalNormalized += clientsResult;
        log('  ✅ Clientes normalizados: $clientsResult');
      }

      log('🎉 Normalização concluída! Total de documentos normalizados: $totalNormalized');

      return Right({
        'message': 'Normalização concluída com sucesso',
        'totalNormalized': totalNormalized,
        'details': report,
      });
    } on FirebaseException catch (e) {
      log('❌ Erro no Firebase durante normalização: ${e.message}');
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log('❌ Erro desconhecido durante normalização: $e');
      return Left(ServiceException(message: 'Erro desconhecido durante normalização: $e'));
    }
  }

  /// Normaliza uma coleção na raiz do Firestore
  Future<int> _normalizeCollection({required String collectionPath, required List<String> dateFields}) async {
    int normalizedCount = 0;

    try {
      final snapshot = await _firestore.collection(collectionPath).get();

      WriteBatch? batch = _firestore.batch();
      int batchCount = 0;
      const batchLimit = 500; // Limite do Firestore

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        bool needsUpdate = false;
        final normalizedData = <String, dynamic>{};

        for (final field in dateFields) {
          if (data.containsKey(field)) {
            final value = data[field];
            if (DateNormalizationHelper.needsNormalization(value)) {
              final normalized = DateNormalizationHelper.normalizeToTimestamp(value);
              if (normalized != null) {
                normalizedData[field] = normalized;
                needsUpdate = true;
              }
            }
          }
        }

        if (needsUpdate) {
          batch!.update(doc.reference, normalizedData);
          batchCount++;
          normalizedCount++;

          // Firestore tem limite de 500 operações por batch
          if (batchCount >= batchLimit) {
            await batch.commit();
            batch = _firestore.batch(); // Criar novo batch
            batchCount = 0;
          }
        }
      }

      // Commit do batch final se houver operações pendentes
      if (batchCount > 0 && batch != null) {
        await batch.commit();
      }
    } catch (e) {
      log('Erro ao normalizar coleção $collectionPath: $e');
      // Continua com outras coleções mesmo se uma falhar
    }

    return normalizedCount;
  }

  /// Normaliza uma subcoleção dentro de um documento pai
  Future<int> _normalizeSubCollection({
    required String parentPath,
    required String collectionName,
    required List<String> dateFields,
    Map<String, List<String>>? nestedDateFields,
  }) async {
    int normalizedCount = 0;

    try {
      final parentParts = parentPath.split('/');
      if (parentParts.length != 2) {
        log('Caminho de parent inválido: $parentPath');
        return 0;
      }

      final collectionRef = _firestore.collection(parentParts[0]).doc(parentParts[1]).collection(collectionName);

      final snapshot = await collectionRef.get();

      WriteBatch? batch = _firestore.batch();
      int batchCount = 0;
      const batchLimit = 500;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        bool needsUpdate = false;
        Map<String, dynamic> normalizedData = Map<String, dynamic>.from(data);

        // Normalizar campos de data diretos
        for (final field in dateFields) {
          if (normalizedData.containsKey(field)) {
            final value = normalizedData[field];
            if (DateNormalizationHelper.needsNormalization(value)) {
              final normalized = DateNormalizationHelper.normalizeToTimestamp(value);
              if (normalized != null) {
                normalizedData[field] = normalized;
                needsUpdate = true;
              }
            }
          }
        }

        // Normalizar campos de data em objetos aninhados
        if (nestedDateFields != null) {
          for (final entry in nestedDateFields.entries) {
            final objectKey = entry.key;
            final dateFields = entry.value;

            if (normalizedData.containsKey(objectKey) && normalizedData[objectKey] is Map<String, dynamic>) {
              final nestedObject = normalizedData[objectKey] as Map<String, dynamic>;

              // Verificar se algum campo de data precisa ser normalizado
              for (final field in dateFields) {
                if (nestedObject.containsKey(field)) {
                  final value = nestedObject[field];
                  if (DateNormalizationHelper.needsNormalization(value)) {
                    final normalized = DateNormalizationHelper.normalizeToTimestamp(value);
                    if (normalized != null) {
                      nestedObject[field] = normalized;
                      needsUpdate = true;
                    }
                  }
                }
              }

              normalizedData[objectKey] = nestedObject;
            }
          }
        }

        if (needsUpdate) {
          // Preparar apenas os campos que mudaram para o update
          final updateData = <String, dynamic>{};

          for (final field in dateFields) {
            if (normalizedData.containsKey(field) && normalizedData[field] != data[field]) {
              updateData[field] = normalizedData[field];
            }
          }

          if (nestedDateFields != null) {
            for (final entry in nestedDateFields.entries) {
              if (normalizedData.containsKey(entry.key) && normalizedData[entry.key] != data[entry.key]) {
                updateData[entry.key] = normalizedData[entry.key];
              }
            }
          }

          if (updateData.isNotEmpty) {
            batch!.update(doc.reference, updateData);
            batchCount++;
            normalizedCount++;

            if (batchCount >= batchLimit) {
              await batch.commit();
              batch = _firestore.batch(); // Criar novo batch
              batchCount = 0;
            }
          }
        }
      }

      if (batchCount > 0 && batch != null) {
        await batch.commit();
      }
    } catch (e) {
      log('Erro ao normalizar subcoleção $collectionName em $parentPath: $e');
    }

    return normalizedCount;
  }
}
