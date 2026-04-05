import 'package:flutter/material.dart';
import 'package:fx_ui/fx_ui.dart';

class FxCheckboxGroupFormField<T> extends FormField<List<T>> {
  FxCheckboxGroupFormField({
    super.key,
    required List<T> items,
    required List<T> selectedItems,
    List<T>? initialSelectedItems,
    required FxDropdownLabel Function(T) itemLabelBuilder,
    required ValueChanged<List<T>> onChanged,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: initialSelectedItems ?? [],
         builder: (FormFieldState<List<T>> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               FxCheckboxGroup<T>(
                 items: items,
                 selectedItems: selectedItems,
                 itemLabelBuilder: itemLabelBuilder,
                 onChanged: (selectedItems) {
                   state.didChange(selectedItems);
                   return onChanged(selectedItems);
                 },
               ),
               if (state.hasError)
                 Padding(
                   padding: FxTheme.smallPadding,
                   child: Text(
                     state.errorText!,
                     style: TextStyle(color: ColorScheme.light().errorContainer, fontSize: 12),
                   ),
                 ),
             ],
           );
         },
       );
}
