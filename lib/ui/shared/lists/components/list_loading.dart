import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ListLoading extends StatelessWidget {
  const ListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1250),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: 3,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 300,
            width: 200,
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  const Avatar(initials: '').asSkeleton(),
                  const Text('Skeleton Example 1'),
                  Wrap(children: [Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit')]),
                  Wrap(children: [Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')]),
                ],
              ),
            ).paddingAll(10),
          );
        },
      ).asSkeleton().paddingOnly(top: 20),
    );
  }
}
