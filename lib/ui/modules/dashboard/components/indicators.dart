import 'package:flutter/material.dart';
import 'package:fx_ui/fx_ui.dart';

class Indicators extends StatelessWidget {
  final String title;
  final int indicator;
  final String subTitle;
  final IconData icon;

  const Indicators({
    super.key,
    required this.title,
    required this.indicator,
    required this.subTitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FxCard(
      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            spacing: FxTheme.smallSpacing,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(indicator.toString(), style: Theme.of(context).textTheme.headlineSmall),
              Text(
                subTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey[300]),
              ),
            ],
          ),
          Icon(icon, size: 35),
        ],
      ),
    );
  }
}
