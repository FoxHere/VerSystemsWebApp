import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class DepartmentDetailsSheet extends StatelessWidget {
  final DepartmentModel department;
  final VoidCallback onExit;

  const DepartmentDetailsSheet({super.key, required this.department, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 850,
      color: theme.colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Detalhes do Departamento').h3(), Text('Visualização somente leitura').muted().small()],
                  ),
                ),
                IconButton.ghost(icon: const Icon(Symbols.close), onPressed: () => onExit()),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FxDivider(title: 'Dados do Departamento', icon: Symbols.domain),
                  _buildDetailRow('Nome do Departamento', department.name),
                  if (department.managerName != null && department.managerName!.isNotEmpty)
                    _buildDetailRow('Responsável / Gestor', department.managerName!),
                  _buildDetailRow('Descrição / Atribuições', department.description),
                  _buildDetailRow('Status', department.departmentStatus.name.capitalizeFirst ?? ''),

                  const SizedBox(height: 24),
                  const FxDivider(title: 'Localização & Contato', icon: Symbols.meeting_room),
                  if (department.location != null && department.location!.isNotEmpty)
                    _buildDetailRow('Local (Andar, Sala, Prédio)', department.location!),
                  if (department.contactEmail != null && department.contactEmail!.isNotEmpty)
                    _buildDetailRow('E-mail do Departamento', department.contactEmail!),
                  if (department.contactPhone != null && department.contactPhone!.isNotEmpty)
                    _buildDetailRow('Telefone / Ramal', department.contactPhone!),

                  if (department.notes != null && department.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const FxDivider(title: 'Observações Finais', icon: Symbols.notes),
                    Text(department.notes!).muted().small(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(label).small().muted(), const SizedBox(height: 4), Text(value).semiBold()],
      ),
    );
  }
}
