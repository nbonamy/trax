import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../model/track.dart';
import '../utils/artist_image_provider.dart';
import '../utils/monogram.dart';
import 'trax_colors.dart';

/// Round avatar of an artist: their picture when one can be found, otherwise a
/// colored monogram that is stable for a given name.
class ArtistProfilePic extends StatelessWidget {
  static const double kDefaultSize = 24;

  final String name;
  final bool selected;
  final double size;

  const ArtistProfilePic({
    super.key,
    required this.name,
    required this.selected,
    this.size = kDefaultSize,
  });

  @override
  Widget build(BuildContext context) {
    // special entries
    if (name == Track.kArtistsHome || name == Track.kArtistCompilations) {
      return _icon(context);
    }

    // nothing to look up
    if (name.isEmpty) {
      return _monogram(context);
    }

    return FutureBuilder<String?>(
      key: ValueKey(name),
      future: context.read<ArtistImageProvider>().imageUrl(name),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) return _monogram(context);
        return CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          placeholder: (context, url) => _monogram(context),
          errorWidget: (context, url, error) => _monogram(context),
          imageBuilder: (context, imageProvider) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  Widget _icon(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    final IconData icon = name == Track.kArtistsHome
        ? CupertinoIcons.home
        : CupertinoIcons.smallcircle_circle_fill;
    return SizedBox(
      width: size,
      height: size,
      child: Icon(
        icon,
        size: size - 4,
        color: selected ? colors.accentInk : colors.accent,
      ),
    );
  }

  Widget _monogram(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    final MonogramColors m = monogramColors(name, colors.brightness);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: m.background),
      child: Text(
        artistInitials(name),
        maxLines: 1,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          height: 1,
          color: m.foreground,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
