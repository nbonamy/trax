import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../model/track.dart';
import '../utils/artwork_provider.dart';
import 'artwork.dart';

class AsyncArtwork extends StatelessWidget {
  final Track? track;
  final double size;
  final double radius;
  final Widget? placeholder;
  final Color defaultPlaceholderBorderColor;
  const AsyncArtwork({
    super.key,
    required this.track,
    required this.size,
    this.radius = 8.0,
    this.placeholder,
    this.defaultPlaceholderBorderColor = CupertinoColors.lightBackgroundGray,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtworkProvider>(
      builder: (context, artworkProvider, child) => FutureBuilder(
        future: artworkProvider.getArwork(track),
        builder: (context, snapshot) => ArtworkWidget(
          bytes: snapshot.connectionState == ConnectionState.done
              ? snapshot.data
              : null,
          size: size,
          radius: radius,
          placeholder: placeholder,
          defaultPlaceholderBorderColor: defaultPlaceholderBorderColor,
        ),
      ),
    );
  }
}
