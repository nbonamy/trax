import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';

import '../model/track.dart';
import '../utils/events.dart';
import '../utils/track_utils.dart';
import 'artwork_async.dart';
import 'database_builder.dart';

class RecentlyAddedWidget extends StatelessWidget {
  const RecentlyAddedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DatabaseBuilder(
      future: (database) => database.recents(20),
      builder: (context, database, recents) => ExtendedWrap(
        maxLines: 2,
        spacing: 32,
        runSpacing: 32,
        clipBehavior: Clip.hardEdge,
        children: recents.keys.toList().map((a) {
          Track track = recents[a]!.first;
          return MouseRegion(
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
                    AsyncArtwork(
                      track: track,
                      size: 192,
                    ),
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
          );
        }).toList(),
      ),
    );
  }
}
