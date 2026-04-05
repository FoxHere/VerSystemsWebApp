import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/services/excel/excel_services.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';

class ImportExcelDialog extends StatefulWidget {
  final void Function(FormularyModel) onImport;
  final String formularyId;
  const ImportExcelDialog({super.key, required this.onImport, required this.formularyId});

  @override
  State<ImportExcelDialog> createState() => _ImportExcelDialogState();
}

class _ImportExcelDialogState extends State<ImportExcelDialog> {
  final formulary = Rxn<FormularyModel>();
  final fileName = RxnString();
  final isUploading = false.obs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar Planilha de Questões'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(Symbols.download, size: 20, color: Theme.of(context).colorScheme.primary),
                    const Text('Passo 1: Obter o modelo').medium(),
                  ],
                ),
                const Text('Baixe o template padrão para garantir que os dados sejam importados corretamente.').muted().small(),
                OutlineButton(
                  onPressed: () async {
                    await ExcelTemplateService.downloadTemplate();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [Icon(Symbols.file_download, size: 18), Text('Baixar Template Excel')],
                  ),
                ),
              ],
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(Symbols.upload_file, size: 20, color: Theme.of(context).colorScheme.primary),
                    const Text('Passo 2: Enviar arquivo preenchido').medium(),
                  ],
                ),
                const Text('Selecione o arquivo Excel com as questões preenchidas.').muted().small(),
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      SecondaryButton(
                        onPressed: isUploading.value
                            ? null
                            : () async {
                                final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
                                if (picked != null) {
                                  isUploading.value = true;
                                  try {
                                    final fileBytes = picked.files.single.bytes!;
                                    fileName.value = picked.files.single.name;
                                    formulary.value = await ExcelTemplateService.parseExcel(fileBytes, widget.formularyId);
                                  } finally {
                                    isUploading.value = false;
                                  }
                                }
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            if (isUploading.value) const CircularProgressIndicator() else const Icon(Symbols.attach_file, size: 18),
                            Text(fileName.value != null ? 'Trocar Arquivo' : 'Selecionar Arquivo'),
                          ],
                        ),
                      ),
                      if (fileName.value != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.muted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.border),
                          ),
                          child: Row(
                            spacing: 8,
                            children: [
                              const Icon(Symbols.description, size: 16, color: Colors.green),
                              Expanded(child: Text(fileName.value!).small().medium()),
                              GhostButton(
                                density: ButtonDensity.compact,
                                onPressed: () {
                                  formulary.value = null;
                                  fileName.value = null;
                                },
                                child: const Icon(Symbols.close, size: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      actions: [
        GhostButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
        Obx(() {
          return PrimaryButton(
            onPressed: (formulary.value == null || isUploading.value)
                ? null
                : () {
                    widget.onImport(formulary.value!);
                    if (context.mounted) context.pop();
                  },
            child: const Text('Confirmar Importação'),
          );
        }),
      ],
    );
  }
}
