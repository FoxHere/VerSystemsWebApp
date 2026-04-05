import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'package:image/image.dart' as img;
import 'package:versystems_app/config/exceptions/service_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class ImageServices {
  final FirebaseStorage _firestorage = FirebaseStorage.instance;

  Future<Either<ServiceException, ImageItemModel>> uploadImage(
    ImageItemModel image,
    String path, {
    bool? hasTimeStamp,
    int quality = 75,
    int? maxWidth,
    bool? useTimeStamp,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Left(ServiceException(message: 'Usuário não autenticado para upload'));
      }
      final jpgBytes = image.bytes;
      final timestamp = hasTimeStamp != null && hasTimeStamp ? '${DateTime.now().millisecondsSinceEpoch}_' : '';
      final fileName = '$timestamp${_getJpgFileName(image.name)}';

      final ref = _firestorage.ref().child('$path/$fileName');
      // final metadata = SettableMetadata(contentType: 'image/${image.name.split('.').last}');

      final uploadTask = ref.putData(jpgBytes); //, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      final FullMetadata metadata = await snapshot.ref.getMetadata();
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(
        ImageItemModel(
          bytes: Uint8List(0),
          downloadUrl: downloadUrl,
          fullPath: metadata.fullPath,
          name: fileName,
          sizeBytes: metadata.size!,
          bucket: metadata.bucket,
        ),
      );
    } on FirebaseException catch (e) {
      return Left(ServiceException(message: HandleFbMessageHelper.handleFBException(e)));
    } on SocketException catch (_) {
      return Left(ServiceException(message: 'Sem conexão com a internet. Verifique sua conexão.'));
    } catch (e) {
      log(e.toString());

      return Left(ServiceException(message: 'Erro desconhecido erro: ${e.toString()}'));
    }
  }

  Future<String> uploadSignature(Uint8List bytes) async {
    final fileName = "signature_${DateTime.now().millisecondsSinceEpoch}.png";
    final ref = FirebaseStorage.instance.ref().child("signatures/$fileName");
    await ref.putData(bytes, SettableMetadata(contentType: "image/png"));

    return await ref.getDownloadURL();
  }

  Future<Either<ServiceException, Unit>> deleteImage(String imageFullPath) async {
    try {
      final ref = FirebaseStorage.instance.ref(imageFullPath);
      await ref.delete();
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

  Future<Uint8List> convertToJpg(Uint8List originalBytes, RxDouble convertProgress, {int quality = 100, int? maxWidth}) async {
    final totalSteps = 3;
    // Resize Image
    convertProgress.value += 1 / totalSteps;
    await Future.delayed(const Duration(milliseconds: 500));
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) {
      throw Exception('Não é possível decodificar a imagem original');
    }
    final resizedImage = maxWidth != null && decodedImage.width > maxWidth ? img.copyResize(decodedImage, width: maxWidth) : decodedImage;
    convertProgress.value += 1 / totalSteps;
    await Future.delayed(const Duration(milliseconds: 500));

    // Enconde to Jpg
    final jpgpBytes = img.encodeJpg(resizedImage, quality: quality);
    convertProgress.value += 1 / totalSteps;
    await Future.delayed(const Duration(milliseconds: 500));
    return jpgpBytes;
  }

  String _getJpgFileName(String originalName) {
    final baseName = originalName.split('.').first;
    return '$baseName.jpg';
  }
}
