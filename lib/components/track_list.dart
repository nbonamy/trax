import 'package:flutter/material.dart';

import '../model/track.dart';
import '../utils/consts.dart';
import '../utils/track_utils.dart';
import 'album.dart';
import 'track.dart';

class TrackListWidget extends StatelessWidget {
  final TrackList tracks;
  final TrackCallback onSelectTrack;
  final TrackCallback onExecuteTrack;
  final bool shrinkWrap;
  final bool primary;
  const TrackListWidget({
    super.key,
    required this.tracks,
    required this.onSelectTrack,
    required this.onExecuteTrack,
    this.shrinkWrap = true,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    bool sameVolume = _areAllSameVolume();
    int previousVolume = -1;

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      primary: primary,
      itemCount: tracks.length + 2,
      itemBuilder: (context, index) {
        if (index == 0 || index > tracks.length) {
          return Container();
        } else {
          return TrackWidget(
            track: tracks[index - 1],
            onTap: (track) => onSelectTrack(track, tracks),
            onDoubleTap: (track) => onExecuteTrack(track, tracks),
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        if (index <= tracks.length - 1) {
          if (!sameVolume) {
            Track track = tracks[index];
            bool volumeChanged = track.volumeIndex != previousVolume;
            previousVolume = track.volumeIndex;
            if (volumeChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (index == 0 ? 12 : 24)),
                  Text(
                    'Disc ${track.volumeIndex}'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(Consts.fadedOpacity),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _lineDivider(),
                ],
              );
            }
          }
        }

        // default
        return _lineDivider();
      },
    );
  }

  bool _areAllSameVolume() {
    for (Track track in tracks) {
      if (track.volumeIndex != tracks.first.volumeIndex) {
        return false;
      }
    }
    return true;
  }

  Widget _lineDivider() {
    return const Divider(height: 0.5);
  }
}
