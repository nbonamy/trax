import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Flex(
        direction: Axis.vertical,
        children: [
          _row(
            t.fileInfoKind,
            track.formatString,
          ),
          _row(
            t.fileInfoDuration,
            track.safeTags.duration.formatDuration(skipHours: true),
          ),
          _row(
            t.fileInfoFileSize,
            track.filesize.formatFilesize(),
          ),
          if (track.safeTags.bitsPerSample != 0)
            _row(
              t.fileInfoBitsPerSample,
              '${track.safeTags.bitsPerSample} bits',
            ),
          if (track.safeTags.sampleRate != 0)
            _row(
              t.fileInfoSampleRate,
              '${track.safeTags.sampleRate} Hz',
            ),
          if (track.safeTags.bitrate != 0)
            _row(
              t.fileInfoBitrate,
              '${track.safeTags.bitrate} kbps',
            ),
          _row(
            t.fileInfoChannels,
            track.channelsString,
          ),
          _row('', ''),
          _row(
            t.fileInfoImported,
            DateTime.fromMillisecondsSinceEpoch(track.importedAt)
                .toString()
                .substring(0, 19),
            tabularFigures: true,
          ),
          _row(
            t.fileInfoModified,
            DateTime.fromMillisecondsSinceEpoch(track.lastModified)
                .toString()
                .substring(0, 19),
            tabularFigures: true,
          ),
          _row('', ''),
          _row(
            t.fileInfoFilePath,
            track.filename,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool tabularFigures = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, 0),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: TextStyle(
                fontFeatures: [
                  if (tabularFigures) const FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String label, double paddingTop) {
    return SizedBox(
      width: 120,
      child: Padding(
        padding: EdgeInsets.only(top: paddingTop, right: 8),
        child: Text(
          label.toLowerCase(),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color.fromRGBO(125, 125, 125, 1.0),
            //fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
