import 'package:shadcn_flutter/shadcn_flutter.dart';

class DashboardMetricCard extends StatelessWidget {
  final String title;
  final int indicator;
  final String subTitle;
  final IconData icon;
  final Color? iconColor;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.indicator,
    required this.subTitle,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? Theme.of(context).colorScheme.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              indicator.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
