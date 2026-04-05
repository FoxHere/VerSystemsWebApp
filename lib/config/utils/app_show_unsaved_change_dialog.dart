import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/config/helpers/app_strings_helper.dart';

Future<bool> showUnsavedChangeDialog(
  BuildContext context, {
  VoidCallback? cancelFunction,
  VoidCallback? exitWitoutSavingFunction,
  VoidCallback? saveAndExitFunction,
}) async {
  return await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(AppStringsHelper.dialogUCTitle),
              content: Row(
                spacing: 10,
                children: [
                  const Icon(Symbols.info, size: 40, color: Colors.orange),
                  const Text(AppStringsHelper.dialogUCMessage),
                ],
              ),
              actions: [
                SizedBox(
                  width: 100,
                  // child: FxButton(
                  //   label: AppStringsHelper.dialogUCCancelBtn,
                  //   onPressed: () {
                  //     cancelFunction != null ? cancelFunction() : null;
                  //     context.pop(false);
                  //   },
                  //   variant: FxButtonVariant.ghost,
                  // ),
                ),

                SizedBox(
                  width: 130,
                  // child: FxButton(
                  //   label: AppStringsHelper.dialogUCExistWithoutSaving,
                  //   onPressed: () {
                  //     exitWitoutSavingFunction != null ? exitWitoutSavingFunction() : null;
                  //     context.pop(true);
                  //   },
                  //   variant: FxButtonVariant.outline,
                  //   buttonType: FxButtontype.error,
                  // ),
                ),
                SizedBox(
                  width: 130,
                  // child: FxButton(
                  //   label: AppStringsHelper.dialogUCExistSave,
                  //   onPressed: () {
                  //     saveAndExitFunction != null ? saveAndExitFunction() : null;
                  //     context.pop(true);
                  //   },
                  //   buttonType: FxButtontype.success,
                  // ),
                ),
              ],
            ),
      ) ??
      false;
}
