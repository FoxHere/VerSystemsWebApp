import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/ui/modules/user_manager/user_form/components/user_form.dart';

/// Wrapper do Step 2 do wizard: dados do administrador inicial.
/// Reutiliza o [UserForm] com [hideAssignments] = true para ocultar
/// os campos de Departamento e Perfil, que serão criados automaticamente
/// pelo SetupViewModel (dept "Geral" + perfil "Administrador").
class StepAdminUserForm extends StatefulWidget {
  final UserModel model;
  const StepAdminUserForm({super.key, required this.model});

  @override
  State<StepAdminUserForm> createState() => StepAdminUserFormState();
}

class StepAdminUserFormState extends State<StepAdminUserForm> {
  final _formKey = GlobalKey<UserFormState>();

  UserModel get userModel => _formKey.currentState?.userModel ?? widget.model;

  bool validateForm() => _formKey.currentState?.validateForm() ?? false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserForm(
                key: _formKey,
                model: widget.model,
                availableDepartmentList: const [],
                availableProfileList: const [],
                availableCompanyList: const [],
                hideAssignments: true,
              ),
              Card(
                child: Row(
                  spacing: 12,
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Departamento e Perfil padrão').semiBold().small(),
                          const Text(
                            'O sistema criará automaticamente o departamento "Geral" e o perfil "Administrador" com acesso total. Você poderá ajustar após o primeiro login.',
                          ).muted().xSmall(),
                        ],
                      ),
                    ),
                  ],
                ).paddingAll(16),
              ).paddingOnly(bottom: 24),
              Card(
                child: Row(
                  spacing: 12,
                  children: [
                    const Icon(Icons.lock_outline, size: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Senha inicial').semiBold().small(),
                          const Text(
                            'A senha padrão gerada é Mudar@123. Altere-a após o primeiro login.',
                          ).muted().xSmall(),
                        ],
                      ),
                    ),
                  ],
                ).paddingAll(16),
              ).paddingOnly(bottom: 48),
            ],
          ),
        ),
      ),
    );
  }
}
