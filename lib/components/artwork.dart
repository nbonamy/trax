import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/consts.dart';

class ArtworkWidget extends StatelessWidget {
  final double size;
  final Uint8List bytes;
  final int trackCount;
  final int playtime;
  const ArtworkWidget(
      {super.key,
      required this.size,
      required this.bytes,
      required this.trackCount,
      required this.playtime});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: size == 0
            ? []
            : [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    bytes,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$trackCount SONGS, $playtime MINUTES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(Consts.fadedOpacity),
                  ),
                ),
              ],
      ),
    );
  }
}
