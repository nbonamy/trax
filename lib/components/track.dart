import 'package:flutter/material.dart';
import 'package:trax/utils/time_utils.dart';

import '../model/track.dart';

class TrackWidget extends StatelessWidget {
  final Track track;
  const TrackWidget({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Text(
            track.trackIndex.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Text(
              track.title,
              maxLines: 1,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            track.tags?.duration.formatDuration(skipHours: true) ?? '',
            style: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
