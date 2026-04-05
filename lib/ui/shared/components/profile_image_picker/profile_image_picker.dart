import 'dart:typed_data';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:versystems_app/ui/shared/components/progress_bar/fx_progress_bar.dart';

class ProfileImagePicker extends StatefulWidget {
  final Function(ImageItemModel?) onImageSelected;
  final ImageItemModel? initialImage;
  final String userName;

  const ProfileImagePicker({super.key, required this.onImageSelected, this.initialImage, required this.userName});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final Rx<ImageItemModel?> _image = Rx<ImageItemModel?>(null);
  final ImagePicker picker = ImagePicker();
  final RxBool isConvetingImage = false.obs;
  final imageServices = Get.find<ImageServices>();
  final convertImageProgress = 0.0.obs;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    final initial = widget.initialImage;
    if (initial != null) {
      final imageUrl = initial.downloadUrl;

      _image.value = ImageItemModel(
        bytes: initial.bytes,
        name: imageUrl != null && imageUrl.isNotEmpty ? imageUrl.split('/').last : initial.name,
        sizeBytes: initial.sizeBytes,
        downloadUrl: imageUrl,
      );
    }
  }

  ImageProvider? _resolveImage(ImageItemModel? image) {
    if (image == null) return null;

    if (image.downloadUrl != null && image.downloadUrl!.isNotEmpty) {
      return NetworkImage(image.downloadUrl!);
    }

    if (image.bytes.isNotEmpty) {
      return MemoryImage(image.bytes);
    }

    return null;
  }

  Future<void> _changeProfilePic(BuildContext context) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      isConvetingImage(true);
      await Future.delayed(const Duration(milliseconds: 500));
      final convertedImage = await imageServices.convertToJpg(bytes, convertImageProgress, maxWidth: 256);
      isConvetingImage(false);
      convertImageProgress.value = 0.0;

      int size = convertedImage.length;
      final newImage = ImageItemModel(bytes: convertedImage, name: 'profile.jpg', sizeBytes: size);

      _image.value = newImage;
      widget.onImageSelected(_image.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4),
              ),
              child: Obx(() {
                final resolvedImage = _resolveImage(_image.value);

                return isConvetingImage.value
                    ? Container(
                        width: 114,
                        height: 114,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4),
                        ),
                        child: FxProgressBar(
                          label: 'Preparando imagem',
                          progress: convertImageProgress,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      )
                    : Avatar(
                        size: 114,
                        provider: resolvedImage,
                        initials: Avatar.getInitials(widget.userName),
                        backgroundColor: Theme.of(context).colorScheme.muted,
                      );
              }),
            ),
            Positioned(
              bottom: 0,
              right: -10,
              child: Obx(() {
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, shape: BoxShape.circle),
                  child: PrimaryButton(
                    onPressed: () => _changeProfilePic(context),
                    enabled: !isConvetingImage.value,
                    shape: ButtonShape.circle,
                    child: const Icon(Symbols.edit, size: 16, color: Colors.white),
                  ),
                );
              }),

              // MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   child: GestureDetector(
              //     onTap: () {
              //       if (!isConvetingImage.value) {
              //         _changeProfilePic(context);
              //       }
              //     },
              //     child: Container(
              //       padding: const EdgeInsets.all(3),
              //       decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, shape: BoxShape.circle),
              //       child: Container(
              //         padding: const EdgeInsets.all(8),
              //         decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              //         child: Obx(() {
              //           if (isConvetingImage.value) {
              //             return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator());
              //           }
              //           return Icon(Symbols.edit, size: 16, color: Colors.white);
              //         }),
              //       ),
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
      ],
    );
  }
}
