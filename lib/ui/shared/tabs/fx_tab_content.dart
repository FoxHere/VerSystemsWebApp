import 'package:flutter/material.dart';
import 'package:versystems_app/ui/shared/tabs/fx_tab_content_empty.dart';

class TabContent extends StatelessWidget {
  final bool validator;
  final Widget trueWidget;
  final String emptyTitle;
  final String? emptySubTitle;
  final String emptyImage;

  const TabContent({
    super.key,
    required this.validator,
    required this.trueWidget,
    required this.emptyTitle,
    required this.emptyImage,
    this.emptySubTitle,
  });

  @override
  Widget build(BuildContext context) {
    return validator ? trueWidget : FxTabContentEmpty(title: emptyTitle, image: emptyImage, subTitle: emptySubTitle);
  }
}
