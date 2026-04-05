import 'package:flutter/material.dart';

class InputSpaceWidget extends StatelessWidget {
  final bool isRequired;
  final Widget child;
  const InputSpaceWidget({
    super.key,
    required this.isRequired,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        if (isRequired) Text('*', style: TextStyle(color: Colors.red)),
        if (!isRequired) const SizedBox(width: 5),
        Expanded(child: child),
      ],
    );
  }
}
