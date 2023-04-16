import 'package:flutter/cupertino.dart';

class AppIcon extends StatelessWidget {
  final double size;
  const AppIcon({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'graphics/app_icon.png',
      width: size,
      height: size,
    );
  }
}
