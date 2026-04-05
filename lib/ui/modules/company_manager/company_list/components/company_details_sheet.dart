import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class CompanyDetailsSheet extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onExit;

  const CompanyDetailsSheet({super.key, required this.company, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstAddress = company.addresses.isNotEmpty ? company.addresses.first : null;

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
                    children: [Text('Detalhes da Empresa').h3(), Text('Visualização somente leitura').muted().small()],
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
                  const FxDivider(title: 'Identidade e Fiscal', icon: Symbols.business),
                  _buildDetailRow('Razão Social', company.name),
                  if (company.tradeName != null && company.tradeName!.isNotEmpty) _buildDetailRow('Nome Fantasia', company.tradeName!),
                  _buildDetailRow('CNPJ', company.cnpj),
                  if (company.stateRegistration != null && company.stateRegistration!.isNotEmpty)
                    _buildDetailRow('Inscrição Estadual', company.stateRegistration!),
                  if (company.municipalRegistration != null && company.municipalRegistration!.isNotEmpty)
                    _buildDetailRow('Inscrição Municipal', company.municipalRegistration!),
                  _buildDetailRow('Status', company.companyStatus.name.capitalizeFirst ?? ''),

                  const SizedBox(height: 24),
                  const FxDivider(title: 'Contato', icon: Symbols.contact_mail),
                  if (company.email != null && company.email!.isNotEmpty) _buildDetailRow('E-mail Principal', company.email!),
                  if (company.phone != null && company.phone!.isNotEmpty) _buildDetailRow('Telefone / WhatsApp', company.phone!),
                  if (company.website != null && company.website!.isNotEmpty) _buildDetailRow('Site Oficial', company.website!),

                  if (firstAddress != null && firstAddress.street.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const FxDivider(title: 'Endereço Sede', icon: Symbols.location_on),
                    _buildDetailRow('Logradouro', '${firstAddress.street}, ${firstAddress.number}'),
                    if (firstAddress.complement.isNotEmpty) _buildDetailRow('Complemento', firstAddress.complement),
                    _buildDetailRow('Bairro', firstAddress.neighborhood),
                    _buildDetailRow('Cidade/UF', '${firstAddress.city} - ${firstAddress.state}'),
                    _buildDetailRow('CEP', firstAddress.zipCode),
                  ],

                  if (company.notes != null && company.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const FxDivider(title: 'Observações Finais', icon: Symbols.notes),
                    Text(company.notes!).muted().small(),
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
