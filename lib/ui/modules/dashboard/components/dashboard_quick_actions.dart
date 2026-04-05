import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ações Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlineButton(
              onPressed: () {
                // Navigate to create formulary
                context.go(RoutesHelper.formulariesManager);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(LucideIcons.filePlus, size: 16), const SizedBox(width: 8), const Text('Novo Formulário')],
              ),
            ),
            OutlineButton(
              onPressed: () {
                // Navigate to create activity
                context.go(RoutesHelper.activityManager);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(LucideIcons.check, size: 16), const SizedBox(width: 8), const Text('Nova Atividade')],
              ),
            ),
            OutlineButton(
              onPressed: () {
                // Navigate to manage members
                context.go(RoutesHelper.usersManager);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(LucideIcons.userPlus, size: 16), const SizedBox(width: 8), const Text('Adicionar Membro')],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
