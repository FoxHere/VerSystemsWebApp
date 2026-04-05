import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

class SetupStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const SetupStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.border,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : isCurrent
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : theme.colorScheme.muted,
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Symbols.check, size: 18, color: theme.colorScheme.primaryForeground)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.mutedForeground,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: isCurrent
                    ? theme.colorScheme.foreground
                    : theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        );
      }),
    );
  }
}
