import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../model/track.dart';
import '../processors/artist_image_provider.dart';

class ArtistProfilePic extends StatelessWidget {
  static const double _kIconSize = 28;
  static const double _kIconPadding = 10;
  static const double _kImageSize = _kIconSize + 2 * _kIconPadding;

  final String name;
  final bool selected;

  static final ArtistImageProvider _artistImageProvider = ArtistImageProvider();

  const ArtistProfilePic({
    Key? key,
    required this.name,
    required this.selected,
  }) : super(key: key);

  IconData get _iconData {
    if (name == Track.kArtistsHome) {
      return CupertinoIcons.home;
    } else if (name == Track.kArtistCompilations) {
      return CupertinoIcons.smallcircle_circle_fill;
    } else {
      return CupertinoIcons.music_mic;
    }
  }

  @override
  Widget build(BuildContext context) {
    // do not even try
    if (name == Track.kArtistsHome ||
        name == Track.kArtistCompilations ||
        name.isEmpty) {
      return _placeholder();
    }

    // try
    return FutureBuilder(
      future: _artistImageProvider.getProfilePicUrl(name),
      builder: (context, snapshot) {
        if (snapshot.hasData == false || snapshot.data == null) {
          return _placeholder();
        }
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          placeholder: (context, url) => _placeholder(),
          errorWidget: (context, url, error) => _placeholder(),
          imageBuilder: (context, imageProvider) => Container(
            width: _kImageSize,
            height: _kImageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      padding: const EdgeInsets.all(_kIconPadding),
      decoration: selected
          ? null
          : BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withOpacity(0.25)),
              color: Colors.black.withOpacity(0.2),
              // gradient: const LinearGradient(
              //   begin: Alignment.bottomCenter,
              //   end: Alignment.topCenter,
              //   colors: [
              //     Color.fromRGBO(135, 140, 150, 1.0),
              //     Color.fromRGBO(164, 170, 182, 1.0),
              //   ],
              // ),
            ),
      child: MacosIcon(
        _iconData,
        size: _kIconSize,
        color: selected ? Colors.white : Colors.black.withOpacity(0.7),
      ),
    );
  }
}
