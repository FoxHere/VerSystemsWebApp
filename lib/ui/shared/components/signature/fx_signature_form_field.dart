import 'dart:typed_data';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:material_symbols_icons/symbols.dart';

class FxSignatureFormField extends StatefulWidget {
  final Function(ImageItemModel) onSignatureSelected;
  final ImageItemModel? initialImage;
  final ImageServices imageServices;
  final RxBool isImageConverting;
  final bool isReadMode;
  final bool isRequired;

  const FxSignatureFormField({
    super.key,
    required this.onSignatureSelected,
    required this.initialImage,
    required this.imageServices,
    required this.isImageConverting,
    this.isReadMode = false,
    this.isRequired = false,
  });

  @override
  State<FxSignatureFormField> createState() => _FxSignatureFormFieldState();
}

class _FxSignatureFormFieldState extends State<FxSignatureFormField> with FormValueSupplier<ImageItemModel, FxSignatureFormField> {
  late SignatureController signatureController;
  final signatureImage = Rx<ImageItemModel?>(null);
  final isSaving = RxBool(false);

  @override
  void initState() {
    super.initState();
    signatureController = SignatureController(penStrokeWidth: 3, penColor: const Color(0xFF000000), exportBackgroundColor: const Color(0xFFFFFFFF));
    initialize();
  }

  @override
  void didReplaceFormValue(ImageItemModel value) {
    if (mounted) {
      signatureImage.value = value;
    }
  }

  @override
  void dispose() {
    signatureController.dispose();
    signatureImage.value = null;
    super.dispose();
  }

  void initialize() async {
    final initialImage = widget.initialImage;
    if (initialImage != null && initialImage.downloadUrl != null) {
      // In a real scenario, this would create an ImageItemModel from the URL
      // If the backend already returns the URL, we could do:
      // final initialModel = ImageItemModel(name: 'signature.jpg', bytes: Uint8List(0), sizeBytes: 0, url: url);
      signatureImage.value = initialImage;
      formValue = initialImage;
    }
  }

  Future<void> _saveSignature(BuildContext dialogContext) async {
    if (signatureController.isEmpty) return;

    final Uint8List? signatureBytes = await signatureController.toPngBytes();
    if (signatureBytes != null) {
      isSaving(true);
      final progress = 0.0.obs;
      try {
        await widget.imageServices.convertToJpg(signatureBytes, progress, maxWidth: 720, quality: 80).then((convertedBytes) {
          final newSig = ImageItemModel(
            name: 'signature_${DateTime.now().millisecondsSinceEpoch}.jpg',
            bytes: convertedBytes,
            sizeBytes: convertedBytes.length,
            downloadUrl: '',
          );
          signatureImage.value = newSig;
          formValue = newSig;
          widget.onSignatureSelected(newSig);
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });
      } finally {
        isSaving(false);
      }
    }
  }

  void _showSignatureDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Área de Assinatura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Assine no quadro abaixo:').muted(),
              const SizedBox(height: 16),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Signature(controller: signatureController, backgroundColor: const Color(0xFFFFFFFF)),
              ),
            ],
          ),
          actions: [
            OutlineButton(
              onPressed: () {
                signatureController.clear();
              },
              child: const Text('Limpar'),
            ),
            OutlineButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
            Obx(() {
              return PrimaryButton(
                leading: const Icon(Symbols.save, size: 16),
                onPressed: isSaving.value ? null : () => _saveSignature(dialogContext),
                child: const Text('Salvar'),
              );
            }),
          ],
        );
      },
    );
  }

  void _removeSignature() {
    signatureController.clear();
    signatureImage.value = null;
    formValue = null;
    widget.onSignatureSelected(ImageItemModel.empty());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sig = signatureImage.value;
      final bool hasSignature = sig != null && (sig.bytes.isNotEmpty || (sig.downloadUrl?.isNotEmpty ?? false));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          if (!hasSignature)
            OutlineButton(
              onPressed: widget.isReadMode ? null : _showSignatureDialog,
              leading: const Icon(Symbols.draw, size: 18),
              child: const Text('Adicionar Assinatura'),
            ),

          if (hasSignature)
            Card(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.border),
                    ),
                    child: (sig.downloadUrl != null && sig.downloadUrl!.isNotEmpty)
                        ? Image.network(sig.downloadUrl!, fit: BoxFit.contain)
                        : Image.memory(sig.bytes, fit: BoxFit.contain),
                  ),
                  if (!widget.isReadMode)
                    Row(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlineButton(onPressed: _removeSignature, leading: const Icon(Symbols.delete, size: 16), child: const Text('Remover')),
                        PrimaryButton(
                          onPressed: _showSignatureDialog,
                          leading: const Icon(Symbols.edit, size: 16),
                          child: const Text('Refazer Assinatura'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
