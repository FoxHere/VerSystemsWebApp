import 'package:flutter/material.dart';

class FxTabContentEmpty extends StatelessWidget {
  const FxTabContentEmpty({super.key, required this.title, required this.image, this.subTitle});
  final String title;
  final String? subTitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Center(
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, fit: BoxFit.cover, height: 300),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
