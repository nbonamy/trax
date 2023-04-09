import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trax/utils/time_utils.dart';

import '../model/selection.dart';
import '../model/track.dart';

class TrackWidget extends StatelessWidget {
  final Track track;
  final Function onSelect;
  const TrackWidget({
    super.key,
    required this.track,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(
      builder: (context, selectionModel, child) {
        SelectionModel selectionModel = SelectionModel.of(context);
        bool selected = selectionModel.contains(track);
        Color bgColor = selected ? Colors.blue : Colors.transparent;
        Color fgColor = selected ? Colors.white : Colors.black;
        Color fgColor2 = selected ? fgColor : fgColor.withOpacity(0.4);
        return GestureDetector(
          onTap: () => onSelect(track),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: bgColor,
            child: Row(
              children: [
                Text(
                  track.trackIndex.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: fgColor2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    track.title,
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
