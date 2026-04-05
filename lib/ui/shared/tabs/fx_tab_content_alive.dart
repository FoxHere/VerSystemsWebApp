import 'package:flutter/material.dart';

class FxTabContentAlive extends StatefulWidget {
  final Widget child;

  const FxTabContentAlive({super.key, required this.child});

  @override
  State<FxTabContentAlive> createState() => _FxTabContentAliveState();
}

class _FxTabContentAliveState extends State<FxTabContentAlive> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
