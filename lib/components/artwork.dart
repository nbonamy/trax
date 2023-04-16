import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ArtworkWidget extends StatelessWidget {
  final Uint8List? bytes;
  final double size;
  final double radius;
  final Widget? placeholder;
  final Color defaultPlaceholderBorderColor;
  const ArtworkWidget({
    super.key,
    required this.bytes,
    required this.size,
    this.radius = 8.0,
    this.placeholder,
    this.defaultPlaceholderBorderColor = CupertinoColors.lightBackgroundGray,
  });

  @override
  Widget build(BuildContext context) {
    return bytes == null
        ? placeholder ??
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(
                  color: defaultPlaceholderBorderColor,
                ),
              ),
            )
        : ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.memory(
              bytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
  }
}
