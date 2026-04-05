import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/gen/assets.gen.dart';

class AppbarWidget extends StatefulWidget {
  const AppbarWidget({super.key, required this.expanded, required this.onExpanded, required this.openDrawer});

  final RxBool expanded;
  final Function(bool value) onExpanded;
  final VoidCallback openDrawer;

  @override
  State<AppbarWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AppbarWidget> with ResponsiveDeviceMixin {
  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return Obx(() {
      return AppBar(
        // title: const Text('Counter App'),
        // subtitle: const Text('A simple counter app'),
        leadingGap: Boudaries.spacing,
        leading: [
          if (widget.expanded.value && isLargeScreen)
            SizedBox(width: 200, child: Assets.images.common.logos.logo01.image(fit: BoxFit.fitHeight, height: 42)),
          if (!widget.expanded.value && !isSmallScreen)
            SizedBox(width: 30, child: Assets.images.common.logos.logo02.image(fit: BoxFit.fitHeight, height: 32)),
          if (isLargeScreen) Gap(Boudaries.spacing / 10),
          // const VerticalDivider(),
          if (!isLargeScreen) OutlineButton(onPressed: widget.openDrawer, density: ButtonDensity.icon, child: const Icon(Icons.menu)),

          // OutlineButton(onPressed: () => widget.onExpanded(!widget.expanded.value), density: ButtonDensity.icon, child: const Icon(Icons.menu)),
        ],
        trailing: [
          // OutlineButton(onPressed: () {}, density: ButtonDensity.icon, child: const Icon(Icons.search)),
          // OutlineButton(onPressed: () {}, density: ButtonDensity.icon, child: const Icon(Icons.add)),
        ],
      );
    });
  }
}
