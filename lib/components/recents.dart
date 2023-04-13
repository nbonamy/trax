import 'dart:collection';

import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/track.dart';
import '../utils/events.dart';
import '../utils/track_utils.dart';
import 'artwork.dart';

class RecentlyAddedWidget extends StatelessWidget {
  const RecentlyAddedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TraxDatabase>(
      builder: (context, database, child) {
        TagLib tagLib = TagLib();
        LinkedHashMap<String, List<Track>> recents = database.recents();
        return ExtendedWrap(
          maxLines: 2,
          spacing: 32,
          runSpacing: 32,
          clipBehavior: Clip.hardEdge,
          children: recents.keys.toList().take(20).map((a) {
            Track track = recents[a]!.first;
            return FutureBuilder(
              future: tagLib.getArtworkBytes(track.filename),
              builder: (context, snapshot) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => eventBus.fire(SelectArtistAlbumEvent(
                    track.safeTags.compilation
                        ? Track.kArtistCompilations
                        : track.safeTags.artist,
                    track.safeTags.album,
                  )),
                  child: SizedBox(
                    width: 192,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ArtworkWidget(bytes: snapshot.data, size: 192),
                        const SizedBox(height: 8),
                        Text(
                          track.displayAlbum,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Text(
                          track.displayAlbumArtist,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
