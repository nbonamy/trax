import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ArtworkWidget extends StatelessWidget {
  final Uint8List? bytes;
  final double size;
  final double radius;
  final Color placeholderBorderColor;
  const ArtworkWidget({
    super.key,
    required this.bytes,
    required this.size,
    this.radius = 8.0,
    this.placeholderBorderColor = CupertinoColors.lightBackgroundGray,
  });

  @override
  Widget build(BuildContext context) {
    return bytes == null
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: placeholderBorderColor,
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.memory(
              bytes!,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          );
  }
}
