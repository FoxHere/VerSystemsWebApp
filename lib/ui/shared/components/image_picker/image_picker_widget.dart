// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_widget.dart';

/// This widget is used to pick multiple images from the gallery or camera.
class ImagePickerWidget extends StatefulWidget {
  final Function(List<ImageItemModel>) onImageSelected;
  final Function(ImageItemModel) onImageRemoved;
  final List<ImageItemModel>? initialImages;
  final ImageServices imageServices;
  final RxBool isImageConverting;
  final bool isReadMode;
  final void Function(List<ImageItemModel>)? onInitialized;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    required this.onImageRemoved,
    required this.imageServices,
    required this.isImageConverting,
    this.onInitialized,
    this.initialImages,
    this.isReadMode = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget>
    with FormValueSupplier<List<ImageItemModel>, ImagePickerWidget> {
  final _images = RxList<ImageItemModel>();
  final ImagePicker picker = ImagePicker();
  final convertProcess = RxDouble(0.0);
  final convertProgressMap = <ImageItemModel, RxDouble>{};
  final canceledConversions = <String>{};

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void didReplaceFormValue(List<ImageItemModel> value) {
    if (mounted) {
      _images.value = value;
    }
  }

  Future<void> initialize() async {
    /// this function get the initial image urls and add them to the list of images
    if (widget.initialImages != null) {
      _images.addAll(widget.initialImages!);
    }
    formValue = _images.toList();
  }

  Future<ImageItemModel> fromUrl(String url) async {
    try {
      // Detecta se está usando o emulador local ou web local
      if (url.contains('127.0.0.1') || url.contains('localhost') || url.startsWith('blob:')) {
        String decodedUrl = Uri.decodeFull(url);
        String fileName = 'Imagem';
        if (decodedUrl.contains('?')) {
          fileName = decodedUrl.split('?').first.split('/').last;
        } else {
          fileName = decodedUrl.split('/').last;
        }
        final ref = FirebaseStorage.instance.refFromURL(url);
        // final metaData = await ref.getMetadata();
        if (fileName.contains('_')) fileName = fileName.split('_').last;
        return ImageItemModel(bytes: Uint8List(0), name: fileName, sizeBytes: 0); //url: url);
      }

      // Para URLs oficiais do Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(url);
      final metaData = await ref.getMetadata();

      String originalName = metaData.name;
      if (originalName.contains('_')) {
        originalName = originalName.substring(originalName.indexOf('_') + 1);
      }

      return ImageItemModel(
        bytes: Uint8List(0),
        name: originalName.isNotEmpty ? originalName : metaData.name,
        sizeBytes: metaData.size ?? 0,
        // url: url,
      );
    } catch (e) {
      debugPrint('Erro ao carregar metadados da imagem de URL: $url\n$e');

      // fallback — tenta exlporar a string da url se o parse falhar
      String decoded = Uri.decodeFull(url);
      String fileName = 'Imagem';
      try {
        String pathPart = decoded.split('?').first;
        fileName = pathPart.split('/').last;
        if (fileName.contains('%2F')) fileName = fileName.split('%2F').last;
        if (fileName.contains('_')) fileName = fileName.substring(fileName.indexOf('_') + 1);
      } catch (_) {}

      return ImageItemModel(bytes: Uint8List(0), name: fileName, sizeBytes: 0); // url: url);
    }
  }

  Future<void> _pickImages(ImageSource source, {required BuildContext context}) async {
    final List<XFile> pickedFileList;

    if (source == ImageSource.gallery) {
      widget.isImageConverting(true);
      pickedFileList = await picker.pickMultiImage();
      if (pickedFileList.isEmpty) {
        widget.isImageConverting(false);
        return;
      }
      final futures = <Future<void>>[];

      for (final file in pickedFileList) {
        final originalBytes = await file.readAsBytes();
        // 1. Criar progresso individual
        final progress = 0.0.obs;
        // 2. Criar placeholder com isLoading
        final placeholder = ImageItemModel(
          bytes: Uint8List(0),
          name: file.name,
          sizeBytes: originalBytes.length,
          isLoading: true,
        );
        // 3. Adicionar à lista visível
        _images.add(placeholder);
        convertProgressMap[placeholder] = progress;
        // 4. Iniciar conversão em paralelo
        final future = widget.imageServices.convertToJpg(originalBytes, progress, maxWidth: 720, quality: 80).then((
          convertedBytes,
        ) {
          // 5. Se foi cancelado, ignore
          if (canceledConversions.contains(file.name)) return;
          final index = _images.indexWhere((img) => img.name == file.name && img.isLoading);
          if (index != -1) {
            _images[index] = ImageItemModel(
              bytes: convertedBytes,
              name: '${file.name.split('.').first}.jpg',
              sizeBytes: convertedBytes.length,
              isLoading: false,
            );
          }
        });
        futures.add(future);
      }
      // Espera todas as conversões finalizarem (em paralelo)
      await Future.wait(futures);
      formValue = _images.toList();
      widget.onImageSelected(_images);
      widget.isImageConverting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _images.isEmpty
          ? Card(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.border, width: 1.5, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 250,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Symbols.cloud_upload, size: 48, color: Theme.of(context).colorScheme.mutedForeground),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Imagem',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adicione imagens da galeria',
                      style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_images.isEmpty && !widget.isReadMode)
                      OutlineButton(
                        leading: Icon(Symbols.image),
                        onPressed: () => _pickImages(ImageSource.gallery, context: context),
                        child: const Text('Galeria'),
                      ),
                  ],
                ),
              ),
            )
          : Card(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(
                      child: Obx(() {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int index = 0; index < _images.length; index++) ...[
                              ImageItemWidget(
                                imageItem: _images[index],
                                convertProcess: convertProgressMap[_images[index]] ?? 0.0.obs,
                                isReadMode: widget.isReadMode,
                                onNameChanged: (newName) {
                                  final currentImage = _images[index];
                                  _images[index] = currentImage.copyWith(name: newName);
                                  formValue = _images.toList();
                                  widget.onImageSelected(_images);
                                },
                                onRemove: () {
                                  canceledConversions.add(_images[index].name);
                                  convertProgressMap.remove(_images[index]);
                                  final removedImage = _images[index];
                                  _images.removeAt(index);
                                  if (!removedImage.isLoading) {
                                    formValue = _images.toList();
                                    widget.onImageSelected(_images);
                                    widget.onImageRemoved(removedImage);
                                  }
                                },
                              ),
                            ],
                            Container(
                              width: 140,
                              height: 260,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.border,
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: GhostButton(
                                  leading: Icon(Symbols.image),
                                  onPressed: widget.isReadMode
                                      ? null
                                      : () => _pickImages(ImageSource.gallery, context: context),
                                  child: Text('Adicionar'),
                                ),
                              ),
                            ).paddingOnly(bottom: 48),
                          ],
                        ).gap(12);
                      }),
                    ),
                  ),
                ),
              ),
            );
    });
  }
}
