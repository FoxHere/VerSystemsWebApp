import 'package:flutter/material.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';

class GetBindingsWrapper extends StatefulWidget {
  final AutoDisposeBindings binding;
  final Widget child;

  const GetBindingsWrapper({super.key, required this.binding, required this.child});

  @override
  State<GetBindingsWrapper> createState() => _GetBindingsWrapperState();
}

class _GetBindingsWrapperState extends State<GetBindingsWrapper> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    for (final disposeCallback in widget.binding.disposeCallbacks) {
      disposeCallback();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.binding.dependencies();
  }
}
