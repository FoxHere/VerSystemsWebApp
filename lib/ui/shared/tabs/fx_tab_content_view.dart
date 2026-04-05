import 'package:flutter/material.dart';
import 'package:versystems_app/ui/shared/tabs/fx_tab_content_alive.dart';

class FxTabContentView extends StatelessWidget {
  const FxTabContentView({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    var controller = DefaultTabController.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(children.length, (index) {
            return Offstage(
              offstage: index != controller.index,
              child: FxTabContentAlive(child: children[index]),
            );
          }),
        );
      },
    );
  }
}
