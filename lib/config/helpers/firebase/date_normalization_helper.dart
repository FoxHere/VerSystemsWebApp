import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper para normalização de datas no Firebase
/// Converte strings de data para Timestamp do Firestore
class DateNormalizationHelper {
  /// Converte um valor que pode ser String ou Timestamp para Timestamp
  ///
  /// Se o valor já for Timestamp, retorna ele mesmo.
  /// Se for String, tenta fazer o parse e converter para Timestamp.
  /// Se for null, retorna null.
  static Timestamp? normalizeToTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value; // Já é Timestamp, não precisa converter
    }

    if (value is String) {
      try {
        final dateTime = DateTime.parse(value);
        return Timestamp.fromDate(dateTime);
      } catch (e) {
        // Se não conseguir fazer parse, retorna null
        return null;
      }
    }

    // Se for outro tipo, retorna null
    return null;
  }

  /// Verifica se um valor precisa ser normalizado (é String mas deveria ser Timestamp)
  static bool needsNormalization(dynamic value) {
    return value != null && value is String;
  }

  /// Normaliza um Map de dados, convertendo campos de data de String para Timestamp
  ///
  /// [data] - O mapa de dados a ser normalizado
  /// [dateFields] - Lista de nomes dos campos que devem ser normalizados
  ///
  /// Retorna um novo Map com os campos normalizados
  static Map<String, dynamic> normalizeDateFields(
    Map<String, dynamic> data,
    List<String> dateFields,
  ) {
    final normalizedData = Map<String, dynamic>.from(data);

    for (final field in dateFields) {
      if (normalizedData.containsKey(field)) {
        final normalized = normalizeToTimestamp(normalizedData[field]);
        if (normalized != null) {
          normalizedData[field] = normalized;
        }
      }
    }

    return normalizedData;
  }

  /// Normaliza campos de data em objetos aninhados
  ///
  /// Útil para normalizar campos dentro de sub-objetos (ex: formulary.createdAt)
  static Map<String, dynamic> normalizeNestedDateFields(
    Map<String, dynamic> data,
    Map<String, List<String>> nestedDateFields,
  ) {
    final normalizedData = Map<String, dynamic>.from(data);

    for (final entry in nestedDateFields.entries) {
      final objectKey = entry.key;
      final dateFields = entry.value;

      if (normalizedData.containsKey(objectKey) &&
          normalizedData[objectKey] is Map<String, dynamic>) {
        final nestedObject = Map<String, dynamic>.from(
          normalizedData[objectKey] as Map<String, dynamic>,
        );

        final normalizedNested = normalizeDateFields(nestedObject, dateFields);
        normalizedData[objectKey] = normalizedNested;
      }
    }

    return normalizedData;
  }
}
