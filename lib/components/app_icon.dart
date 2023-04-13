import 'package:flutter/cupertino.dart';

class AppIcon extends StatelessWidget {
  final double size;
  const AppIcon({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.music_note,
      color: CupertinoColors.systemPurple,
      size: size,
    );
  }
}
