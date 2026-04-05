import 'package:flutter/material.dart';

class FxRadioGroupFormField<T> extends FormField<T> {
  FxRadioGroupFormField({
    super.key,
    required List<T> items,
    required T selectedItem,
    required String Function(T) itemLabelBuilder,
    required ValueChanged<T> onChanged,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: selectedItem,
         builder: (FormFieldState<T> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
              //  FxRadioGroup<T>(
              //    items: items,
              //    selectedItem: selectedItem,
              //    itemLabelBuilder: itemLabelBuilder,
              //    onChanged: (selectedItem) {
              //      if (selectedItem != null) {
              //        state.didChange(selectedItem);
              //        return onChanged(selectedItem);
              //      }
              //    },
              //  ),
              //  if (state.hasError)
              //    Padding(
              //      padding: FxTheme.smallPadding,
              //      child: Text(
              //        state.errorText!,
              //        style: TextStyle(color: ColorScheme.light().errorContainer, fontSize: 12),
              //      ),
              //    ),
             ],
           );
         },
       );
}
