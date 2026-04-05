import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class UserDetailsSheet extends StatelessWidget {
  final UserModel user;
  final VoidCallback onExit;

  const UserDetailsSheet({super.key, required this.user, required this.onExit});

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
                    children: [Text('Detalhes do Usuário').h3(), Text('Visualização somente leitura').muted().small()],
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
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.muted,
                        image: user.profileImage?.downloadUrl != null && user.profileImage!.downloadUrl!.isNotEmpty
                            ? DecorationImage(image: NetworkImage(user.profileImage!.downloadUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: user.profileImage?.downloadUrl == null || user.profileImage!.downloadUrl!.isEmpty
                          ? const Icon(Symbols.person, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const FxDivider(title: 'Dados Pessoais', icon: Symbols.person),
                  _buildDetailRow('Nome', user.name),
                  _buildDetailRow('E-mail', user.email),
                  if (user.cellphones.isNotEmpty) _buildDetailRow('Celular Principal', user.cellphones.first),
                  if (user.telephones.isNotEmpty) _buildDetailRow('Telefone Principal', user.telephones.first),
                  _buildDetailRow('Status', user.userStatus.name.capitalizeFirst ?? ''),

                  const SizedBox(height: 24),
                  const FxDivider(title: 'Acesso e Permissões', icon: Symbols.admin_panel_settings),
                  _buildDetailRow('Cargo / Função', user.role ?? 'Não informado'),
                  _buildDetailRow('Departamento', user.department.name),
                  _buildDetailRow('Perfil de Acesso', user.profile.name),
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
