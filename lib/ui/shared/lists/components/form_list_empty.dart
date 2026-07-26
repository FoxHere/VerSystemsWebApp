import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/boudaries.dart';

class FormListEmpty extends StatelessWidget {
  const FormListEmpty({
    super.key,
    this.title = 'Nenhum registro encontrado',
    this.description = 'Não existem registros cadastrados ou os filtros aplicados não retornaram resultados.',
    this.imagePath = 'assets/images/common/lists/list_empty_state.png',
    this.action,
  });

  final String title;
  final String? description;
  final String imagePath;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Boudaries.spacing * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(32),
            Image.asset(
              imagePath,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(height: 120),
            ),
            const Gap(16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.slate.shade600,
              ),
            ),
            if (description != null) ...[
              const Gap(8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.slate.shade400,
                  ),
                ),
              ),
            ],
            if (action != null) ...[
              const Gap(20),
              action!,
            ],
            const Gap(32),
          ],
        ),
      ),
    );
  }
}
