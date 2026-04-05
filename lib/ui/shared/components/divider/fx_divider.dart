import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FxDivider extends StatelessWidget {
  const FxDivider({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(children: [Icon(icon, size: 20).muted(), const SizedBox(width: 8), Text(title).semiBold()]),
        const Divider().paddingSymmetric(vertical: 8),
        const SizedBox(height: 8),
      ],
    );
  }
}
