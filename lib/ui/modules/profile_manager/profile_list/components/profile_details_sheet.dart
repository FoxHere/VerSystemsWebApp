import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class ProfileDetailsSheet extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onExit;

  const ProfileDetailsSheet({super.key, required this.profile, required this.onExit});

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
                    children: [Text('Detalhes do Perfil').h3(), Text('Visualização somente leitura').muted().small()],
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
                  const FxDivider(title: 'Dados do Perfil', icon: Symbols.shield_person),
                  _buildDetailRow('Nome do Perfil', profile.name),
                  if (profile.description.isNotEmpty) _buildDetailRow('Descrição', profile.description),
                  _buildDetailRow('Status', profile.profileStatus.name.capitalizeFirst ?? ''),

                  const SizedBox(height: 24),
                  const FxDivider(title: 'Acessos e Permissões', icon: Symbols.vpn_key),

                  if (profile.allowedMenus.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Menus Permitidos').small().muted(),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.allowedMenus
                                .map(
                                  (m) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(5)),
                                    child: Text(m).small(),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (profile.allowedMenus.isEmpty) Text('Este perfil não possui menus configurados.').muted().small(),
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
