import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Stack, Column, Row, Positioned, Expanded;
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

class ImageItemWidget extends StatelessWidget {
  final VoidCallback? onRemove;
  final ValueChanged<String>? onNameChanged;
  final ImageItemModel imageItem;
  final RxDouble convertProcess;
  final bool isReadMode;

  const ImageItemWidget({
    super.key,
    this.onRemove,
    this.onNameChanged,
    required this.imageItem,
    required this.convertProcess,
    this.isReadMode = false,
  });

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    final double kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    String readableSize = _formatBytes(imageItem.sizeBytes);

    return SizedBox(
      width: 140,

      child: Stack(
        children: [
          CardImage(
            onPressed: () {
              if (isReadMode) return;

              String baseName = imageItem.name;
              String extension = '';
              final lastDotIndex = baseName.lastIndexOf('.');

              if (lastDotIndex != -1) {
                extension = baseName.substring(lastDotIndex);
                baseName = baseName.substring(0, lastDotIndex);
              }

              final TextEditingController nameController = TextEditingController(text: baseName);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Detalhes da Imagem'),
                    content: SizedBox(
                      width: 400,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image(
                              height: 250,
                              width: double.infinity,
                              image: imageItem.downloadUrl != null && imageItem.downloadUrl!.isNotEmpty
                                  ? NetworkImage(imageItem.downloadUrl!)
                                  : MemoryImage(imageItem.bytes) as ImageProvider,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Symbols.broken_image, size: 80, color: Theme.of(context).colorScheme.mutedForeground),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              const Text('Nome da Imagem').medium(),

                              if (imageItem.bytes.isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(controller: nameController, placeholder: const Text('Insira o nome da imagem')),
                                    ),

                                    if (extension.isNotEmpty) Text(extension).muted().marginOnly(left: 8),
                                  ],
                                ),
                              if (imageItem.bytes.isEmpty) Text(imageItem.name),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      OutlineButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                      PrimaryButton(
                        onPressed: () {
                          if (onNameChanged != null && nameController.text.trim().isNotEmpty) {
                            final newName = nameController.text.trim() + extension;
                            onNameChanged!(newName);
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Salvar'),
                      ),
                    ],
                  );
                },
              );
            },
            image: imageItem.isLoading
                ? Container(
                    width: 140,
                    height: 260,
                    color: Theme.of(context).colorScheme.muted,
                    child: Obx(
                      () => Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        spacing: 8,
                        children: [
                          const CircularProgressIndicator(),
                          Text(
                            '${(convertProcess.value * 100).toInt()}%',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image(
                    height: double.infinity,
                    image: imageItem.downloadUrl != null && imageItem.downloadUrl!.isNotEmpty
                        ? NetworkImage(imageItem.downloadUrl!)
                        : MemoryImage(imageItem.bytes) as ImageProvider,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Symbols.broken_image, size: 40, color: Theme.of(context).colorScheme.mutedForeground),
                  ),
            title: Text(
              imageItem.name.isNotEmpty ? imageItem.name : 'Imagem',
              // style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF), fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: imageItem.sizeBytes > 0 ? Text(readableSize) : const SizedBox.shrink(),
          ),
          if (!isReadMode)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0x8A000000), shape: BoxShape.circle),
                  child: const Icon(Symbols.close, size: 14, color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
