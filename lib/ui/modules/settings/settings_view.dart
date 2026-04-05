import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/user/user_settings_model.dart';
import 'package:versystems_app/ui/modules/settings/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [AppBar(title: const Text('Configurações').h4())],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferências do Aplicativo').h4(),
              const SizedBox(height: 8),
              Text('Gerencie as configurações de sistema para sua conta').muted().base(),
              const SizedBox(height: 24),
              Card(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSettingRow(
                      icon: Symbols.dark_mode,
                      title: 'Tema Escuro',
                      subtitle: 'Alterne entre o tema claro e escuro',
                      trailing: Obx(
                        () => Switch(value: controller.themeMode.value == AppThemeMode.dark, onChanged: (val) => controller.toggleThemeMode()),
                      ),
                    ),
                    const Divider(),
                    _buildSettingRow(
                      icon: Symbols.notifications,
                      title: 'Notificações',
                      subtitle: 'Ativar alertas e mensagens do sistema',
                      trailing: Obx(() => Switch(value: controller.notificationsEnabled.value, onChanged: controller.toggleNotifications)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Icon(icon).iconLarge().muted(),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title).medium(), const SizedBox(height: 4), Text(subtitle).muted()],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
