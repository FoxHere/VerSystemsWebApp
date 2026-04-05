import 'dart:typed_data';

class ImageItemModel {
  final Uint8List bytes; // Bytes da imagem para imagens novas
  final String name; // Nome da imagem
  final String? downloadUrl; // Mostrar a imagem
  final String? fullPath; // Mexer no arquivo no Storage
  final String? bucket; // Para operações internas
  final int sizeBytes; // Tamanho do arquivo
  final bool isLoading; // Opcional, mas útil

  ImageItemModel({
    required this.bytes,
    required this.name,
    required this.sizeBytes,
    this.downloadUrl,
    this.fullPath,
    this.bucket,
    this.isLoading = false,
  });

  Map<String, dynamic> toJsonForFirebase() => {
    'downloadUrl': downloadUrl,
    'fullPath': fullPath ?? '',
    'bucket': bucket ?? '',
    'name': name,
    'sizeBytes': sizeBytes,
  };

  Map<String, dynamic> toJson() => {
    'downloadUrl': downloadUrl,
    'fullPath': fullPath ?? '',
    'bucket': bucket ?? '',
    'name': name,
    'sizeBytes': sizeBytes,
  };

  factory ImageItemModel.empty() {
    return ImageItemModel(bytes: Uint8List(0), name: '', sizeBytes: 0, downloadUrl: null, fullPath: null, bucket: null, isLoading: false);
  }

  factory ImageItemModel.fromFirebase(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return ImageItemModel.empty();
    }

    return ImageItemModel(
      bytes: Uint8List(0),
      name: data['name'] ?? '',
      sizeBytes: data['sizeBytes'] ?? 0,
      downloadUrl: data['downloadUrl'],
      fullPath: data['fullPath'],
      bucket: data['bucket'],
    );
  }

  ImageItemModel copyWith({Uint8List? bytes, String? name, int? sizeBytes, String? downloadUrl, String? fullPath, String? bucket, bool? isLoading}) {
    return ImageItemModel(
      bytes: bytes ?? this.bytes,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fullPath: fullPath ?? this.fullPath,
      bucket: bucket ?? this.bucket,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ImageItemModel.fromJson(Map<String, dynamic> json) {
    return ImageItemModel(
      bytes: Uint8List(0),
      name: json['name'] ?? '',
      sizeBytes: json['sizeBytes'] ?? 0,
      downloadUrl: json['downloadUrl'],
      fullPath: json['fullPath'],
      bucket: json['bucket'],
      isLoading: json['isLoading'] ?? false,
    );
  }
}
// class ImageItemModel {
//   final Uint8List bytes;
//   final String name;
//   final int sizeBytes;
//   final String? url;
//   final bool isLoading;

//   ImageItemModel({
//     required this.bytes,
//     required this.name,
//     required this.sizeBytes,
//     this.url,
//     this.isLoading = false,
//   });

//   factory ImageItemModel.empty() {
//     return ImageItemModel(bytes: Uint8List(0), name: '', sizeBytes: 0, url: null);
//   }

//   ImageItemModel copyWith({
//     Uint8List? bytes,
//     String? name,
//     int? sizeBytes,
//     String? url,
//     bool? isLoading,
//   }) {
//     return ImageItemModel(
//       bytes: bytes ?? this.bytes,
//       name: name ?? this.name,
//       sizeBytes: sizeBytes ?? this.sizeBytes,
//       url: url ?? this.url,
//       isLoading: this.isLoading,
//     );
//   }

//   Map<String, dynamic> toJsonForFirebase() => {
//     'url': url,
//   };

//   factory ImageItemModel.fromFirebase(dynamic data) {
//     if (data == null) {
//       return ImageItemModel(bytes: Uint8List(0), name: '', sizeBytes: 0, url: null);
//     }
//     String? url;
//     if (data is String) {
//       url = data;
//     } else if (data is Map) {
//       url = data['url'] as String?;
//     }
//     return ImageItemModel(bytes: Uint8List(0), name: '', sizeBytes: 0, url: url);
//   }
// }
