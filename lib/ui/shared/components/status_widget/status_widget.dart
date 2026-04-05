import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/has_model_status.dart';

class StatusWidget<T extends StatusVisual> extends StatelessWidget {
  final T status;
  final IconData icon;

  const StatusWidget({super.key, required this.status, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      width: 100,
      // padding: FxTheme.smallPadding / 2,
      decoration: BoxDecoration(
        // borderRadius: FxTheme.borderRadiusAll / 2,
        color: color.withValues(alpha: 0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 7,
        children: [
          Icon(icon, color: color, size: 16),
          Text(status.label, style: TextStyle(color: color)).small(),
        ],
      ),
    );
  }
}
