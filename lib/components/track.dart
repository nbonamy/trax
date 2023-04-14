import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/selection.dart';
import '../model/track.dart';
import '../utils/consts.dart';
import '../utils/time_utils.dart';
import '../utils/track_utils.dart';

class TrackWidget extends StatelessWidget {
  final Track track;
  final Function onTap;
  final Function onDoubleTap;
  const TrackWidget({
    super.key,
    required this.track,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(
      builder: (context, selectionModel, child) {
        SelectionModel selectionModel = SelectionModel.of(context);
        bool selected = selectionModel.contains(track);
        Color bgColor = selected ? Colors.blue : Colors.transparent;
        Color fgColor = selected ? Colors.white : Colors.black;
        Color fgColor2 =
            selected ? fgColor : fgColor.withOpacity(Consts.fadedOpacity);
        return GestureDetector(
          onTapDown: (_) => onTap(track),
          onDoubleTap: () => onDoubleTap(track),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: bgColor,
            child: Row(
              children: [
                Text(
                  track.displayTrackIndex,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: fgColor2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    track.displayTitle,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      color: fgColor,
                    ),
                  ),
                ),
                Text(
                  track.tags?.duration.formatDuration(skipHours: true) ?? '',
                  style: TextStyle(
                    color: fgColor2,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
