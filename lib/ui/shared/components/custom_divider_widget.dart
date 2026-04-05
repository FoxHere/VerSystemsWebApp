import 'package:flutter/material.dart';

class CustomDividerWidget extends StatelessWidget {
  const CustomDividerWidget({
    super.key,
    required this.label,
    required this.customSymbol,
  });

  final String label;
  final IconData customSymbol;
  final Color greyColor = const Color(0xff6B7280);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 20.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                customSymbol,
                color: greyColor,
                size: 20,
                weight: 600,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }
}
