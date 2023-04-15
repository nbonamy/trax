import 'package:flutter/material.dart';

import '../model/track.dart';
import '../utils/num_utils.dart';

class EditorFileWidget extends StatelessWidget {
  final Track track;
  const EditorFileWidget({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Flex(
        direction: Axis.vertical,
        children: [
          _row('kind', track.formatString),
          _row('duration',
              track.safeTags.duration.formatDuration(skipHours: true)),
          _row('size', track.filesize.formatFilesize()),
          if (track.safeTags.bitsPerSample != 0)
            _row('bits per sample', '${track.safeTags.bitsPerSample} bits'),
          if (track.safeTags.sampleRate != 0)
            _row('sample rate', '${track.safeTags.sampleRate} Hz'),
          if (track.safeTags.bitrate != 0)
            _row('bitate', '${track.safeTags.bitrate} kbps'),
          _row('channels', track.channelsString),
          _row('', ''),
          _row(
              'date modified',
              DateTime.fromMillisecondsSinceEpoch(track.lastModified)
                  .toString()
                  .substring(0, 19)),
          _row('', ''),
          _row('location', track.filename),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, 0),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String label, double paddingTop) {
    return SizedBox(
      width: 130,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop, right: 8),
        child: Text(
          label.toLowerCase(),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color.fromRGBO(125, 125, 125, 1.0),
          ),
        ),
      ),
    );
  }
}
