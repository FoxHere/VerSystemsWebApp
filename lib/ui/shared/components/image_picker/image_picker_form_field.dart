import 'package:flutter/material.dart';
import 'package:fx_ui/fx_ui.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_picker_widget.dart';

class ImagePickerFormField extends FormField<List<ImageItemModel>> {
  ImagePickerFormField({
    super.key,
    List<String>? initialUrls,
    required ImageServices imageServices,
    super.onSaved,
    super.validator,
    required Function(List<ImageItemModel>) onImageSelected,
    required Function(ImageItemModel) onImageRemoved,
    required RxBool isImageConverting,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    bool isReadMode = false,
  }) : super(
         initialValue: const [],
         builder: (FormFieldState<List<ImageItemModel>> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               ImagePickerWidget(
                 initialImages: [],
                 imageServices: imageServices,
                 isImageConverting: isImageConverting,
                 isReadMode: isReadMode,
                 onImageSelected: (img) {
                   state.didChange(img);
                   return onImageSelected(img);
                 },
                 onImageRemoved: (img) {
                   final current = List<ImageItemModel>.from(state.value ?? []);
                   current.remove(img);
                   state.didChange(current);
                   return onImageRemoved(img);
                 },
                 onInitialized: (initialImages) {
                   if ((state.value ?? []).isEmpty && initialImages.isNotEmpty) {
                     state.didChange(initialImages);
                   }
                 },
               ),
               if (state.hasError)
                 Padding(
                   padding: FxTheme.smallPadding,
                   child: Text(state.errorText!, style: TextStyle(color: ColorScheme.light().errorContainer, fontSize: 12)),
                 ),
             ],
           );
         },
       );
}
