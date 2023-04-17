import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/track.dart';
import '../utils/consts.dart';
import '../utils/track_utils.dart';
import 'artist_profile_pic.dart';

class ArtistWidget extends StatelessWidget {
  final String name;
  final bool selected;
  final Function onSelectArtist;
  const ArtistWidget({
    super.key,
    required this.name,
    required this.selected,
    required this.onSelectArtist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
          color: selected ? Consts.sideBarSelectBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onSelectArtist(name),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ArtistProfilePic(
                selected: selected,
                iconData: name == Track.kArtistsHome
                    ? CupertinoIcons.home
                    : name == Track.kArtistCompilations
                        ? CupertinoIcons.smallcircle_circle_fill
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  TrackUtils.getDisplayArtist(name),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Consts.sideBarSelectFgColor
                        : Consts.sideBarFgColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
