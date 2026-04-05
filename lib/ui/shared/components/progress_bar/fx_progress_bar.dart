import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FxProgressBar extends StatefulWidget {
  final String label;
  final RxDouble progress;
  final TextStyle? labelStyle;

  const FxProgressBar({super.key, required this.progress, required this.label, this.labelStyle});

  @override
  State<FxProgressBar> createState() => _FxProgressBarState();
}

class _FxProgressBarState extends State<FxProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lProgress = widget.progress.value.clamp(0.0, 1.0);

      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: widget.labelStyle,
            ),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(10),
              value: lProgress,
              backgroundColor: Colors.grey,
              color: Colors.blue,
              minHeight: 10,
            ),
          ],
        ),
      );
    });
  }
}
