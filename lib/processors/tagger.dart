import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../components/dialog.dart';
import '../data/database.dart';
import '../model/track.dart';

class Tagger {
  final BuildContext context;
  final TraxDatabase database;

  Tagger(this.context, this.database);

  void cleanupTitles(TrackList tracks) {
    // needed
    AppLocalizations t = AppLocalizations.of(context)!;

    // check if comments are empty
    bool allCommentsEmpty = _allCommentsEmpty(tracks);
    TraxDialog.confirm(
      context: context,
      text: allCommentsEmpty
          ? t.cleanupTitleCommentsEmpty
          : t.cleanupTitleCommentsNotEmpty,
      isDestructive: !allCommentsEmpty,
      onConfirmed: (context) {
        Navigator.of(context).pop();
        _cleanupTitles(
          tracks,
          true,
        );
      },
    );
  }

  void _cleanupTitles(TrackList tracks, bool moveToComments) {
    // we need a taglib
    TagLib tagLib = TagLib();

    // now for each track
    for (Track track in tracks) {
      // get suffix
      String? suffix = _findSuffix(track);
      if (suffix == null) continue;

      // reload from disk and make sure it is up to date
      Tags tags = tagLib.getAudioTags(track.filename);
      if (tags.title != track.tags?.title) continue;

      // now update tags
      tags.title = tags.title
          .substring(0, tags.title.length - suffix.length)
          .trimRight();
      if (moveToComments) {
        tags.comment = _cleanSuffix(suffix);
      }

      // save on file and in db
      track.tags = tags;
      tagLib.setAudioTags(track.filename, tags);
      database.insert(track, notify: false);
    }

    // done
    database.notify();
  }

  String? _findSuffix(Track track) {
    // title
    String title = track.tags?.title ?? '';
    if (title.isEmpty) return null;
    if (title.endsWith(')')) {
      int index = title.lastIndexOf('(');
      if (index < 0) return null;
      return title.substring(index, title.length);
    } else if (title.endsWith(']')) {
      int index = title.lastIndexOf('[');
      if (index < 0) return null;
      return title.substring(index, title.length);
    } else {
      return null;
    }
  }

  // bool _allEndsWith(TrackList tracks, String suffix) {
  //   for (Track track in tracks) {
  //     if (track.tags?.title == null ||
  //         track.tags!.title.endsWith(suffix) == false) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  bool _allCommentsEmpty(TrackList tracks) {
    for (Track track in tracks) {
      if (track.tags?.comment != null && track.tags!.comment.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  String _cleanSuffix(String suffix) {
    while (true) {
      String initial = suffix;
      suffix = suffix.trim();
      if (suffix.startsWith('(') && suffix.endsWith(')')) {
        suffix = suffix.substring(1, suffix.length - 1);
      }
      if (suffix.startsWith('[') && suffix.endsWith(']')) {
        suffix = suffix.substring(1, suffix.length - 1);
      }
      if (suffix == initial) break;
    }
    return suffix;
  }
}
