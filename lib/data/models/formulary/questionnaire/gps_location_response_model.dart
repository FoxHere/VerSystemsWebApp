import 'package:cloud_firestore/cloud_firestore.dart';

class GpsLocationResponseModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime capturedAt;

  GpsLocationResponseModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
  });

  factory GpsLocationResponseModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    if (json['geoPoint'] != null) {
      final gp = json['geoPoint'];
      if (gp is GeoPoint) {
        lat = gp.latitude;
        lng = gp.longitude;
      } else if (gp is Map) {
        lat = (gp['latitude'] as num?)?.toDouble() ?? 0.0;
        lng = (gp['longitude'] as num?)?.toDouble() ?? 0.0;
      }
    } else {
      lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    final acc = (json['accuracy'] as num?)?.toDouble() ?? 0.0;

    final rawCaptured = json['capturedAt'];
    DateTime capAt = DateTime.now();
    if (rawCaptured != null) {
      if (rawCaptured is Timestamp) {
        capAt = rawCaptured.toDate();
      } else if (rawCaptured is String) {
        capAt = DateTime.tryParse(rawCaptured) ?? DateTime.now();
      } else if (rawCaptured is int) {
        capAt = DateTime.fromMillisecondsSinceEpoch(rawCaptured);
      }
    }

    return GpsLocationResponseModel(
      latitude: lat,
      longitude: lng,
      accuracy: acc,
      capturedAt: capAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForFirebase() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'geoPoint': GeoPoint(latitude, longitude),
      'accuracy': accuracy,
      'capturedAt': Timestamp.fromDate(capturedAt),
    };
  }

  GpsLocationResponseModel copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? capturedAt,
  }) {
    return GpsLocationResponseModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}
