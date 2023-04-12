import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/utils/events.dart';

import '../components/artwork.dart';
import '../data/database.dart';
import '../model/track.dart';
import '../utils/track_utils.dart';

class StartWidget extends StatelessWidget {
  const StartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(128),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.addedRecently,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<TraxDatabase>(
            builder: (context, database, child) {
              TagLib tagLib = TagLib();
              LinkedHashMap<String, List<Track>> recents = database.recents();
              return Wrap(
                children: recents.keys.map((a) {
                  Track track = recents[a]!.first;
                  Uint8List? artworkBytes =
                      tagLib.getArtworkBytes(track.filename);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => eventBus
                            .fire(SelectArtistEvent(track.safeTags.artist)),
                        child: SizedBox(
                          width: 192,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ArtworkWidget(bytes: artworkBytes, size: 192),
                              const SizedBox(height: 8),
                              Text(
                                track.displayAlbum,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              Text(
                                track.displayArtist,
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
          ),
        ],
      ),
    );
  }
}
