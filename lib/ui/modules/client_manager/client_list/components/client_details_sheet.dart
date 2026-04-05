import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class ClientDetailsSheet extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onExit;

  const ClientDetailsSheet({super.key, required this.client, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhysical = client.clientType == ClientType.physical;
    final firstAddress = client.addresses.isNotEmpty ? client.addresses.first : null;

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
                    children: [Text('Detalhes do Cliente').h3(), Text('Visualização somente leitura').muted().small()],
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
                  const FxDivider(title: 'Dados Principais', icon: Symbols.badge),
                  _buildDetailRow('Nome / Razão Social', client.name),
                  _buildDetailRow('Tipo', isPhysical ? 'Pessoa Física' : 'Pessoa Jurídica'),
                  if (isPhysical && client.cpf != null && client.cpf!.isNotEmpty) _buildDetailRow('CPF', client.cpf!),
                  if (!isPhysical && client.cnpj != null && client.cnpj!.isNotEmpty) _buildDetailRow('CNPJ', client.cnpj!),
                  _buildDetailRow('Status', client.clientStatus.name.capitalizeFirst ?? ''),

                  const SizedBox(height: 24),
                  const FxDivider(title: 'Contato', icon: Symbols.contact_mail),
                  _buildDetailRow('E-mail', client.email),
                  _buildDetailRow('Telefone', client.phone),

                  if (firstAddress != null && firstAddress.street.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const FxDivider(title: 'Endereço', icon: Symbols.location_on),
                    _buildDetailRow('Logradouro', '${firstAddress.street}, ${firstAddress.number}'),
                    if (firstAddress.complement.isNotEmpty) _buildDetailRow('Complemento', firstAddress.complement),
                    _buildDetailRow('Bairro', firstAddress.neighborhood),
                    _buildDetailRow('Cidade/UF', '${firstAddress.city} - ${firstAddress.state}'),
                    _buildDetailRow('CEP', firstAddress.zipCode),
                  ],

                  if (client.notes != null && client.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const FxDivider(title: 'Observações Finais', icon: Symbols.notes),
                    Text(client.notes!).muted().small(),
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
