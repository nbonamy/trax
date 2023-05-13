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

    // find a common suffix
    String? suffix = _findCommonSuffix(tracks);
    if (suffix == null) {
      TraxDialog.inform(context: context, message: t.cleanupTitleError);
      return;
    }

    // check if comments are empty
    bool allCommentsEmpty = _allCommentsEmpty(tracks);
    TraxDialog.confirm(
      context: context,
      text: allCommentsEmpty
          ? t.cleanupTitleWithCopyToComment
          : t.cleanupTitleWithoutCopyToComment,
      onConfirmed: (context) {
        Navigator.of(context).pop();
        _cleanupTitles(
          tracks,
          suffix,
          allCommentsEmpty,
        );
      },
    );
  }

  void _cleanupTitles(TrackList tracks, String suffix, bool moveToComments) {
    // we need a taglib
    TagLib tagLib = TagLib();

    // get a clean suffix for comments
    String cleanSuffix = _cleanSuffix(suffix);

    // now for each track
    for (Track track in tracks) {
      // reload from disk and make sure it is up to date
      Tags tags = tagLib.getAudioTags(track.filename);
      if (tags.title != track.tags?.title) continue;

      // now update tags
      tags.title = tags.title
          .substring(0, tags.title.length - suffix.length)
          .trimRight();
      if (moveToComments) {
        tags.comment = cleanSuffix;
      }

      // save on file and in db
      track.tags = tags;
      tagLib.setAudioTags(track.filename, tags);
      database.insert(track, notify: false);
    }

    // done
    database.notify();
  }

  String? _findCommonSuffix(TrackList tracks) {
    //
    int length = 1;
    String? suffix;
    String? title = tracks.first.tags?.title;
    if (title == null) return null;
    while (true) {
      String testSuffix = title.substring(title.length - length);
      bool allEndsWith = _allEndsWith(tracks, testSuffix);
      if (allEndsWith == false) {
        break;
      } else {
        suffix = testSuffix;
        length++;
      }
    }
    return suffix;
  }

  bool _allEndsWith(TrackList tracks, String suffix) {
    for (Track track in tracks) {
      if (track.tags?.title == null ||
          track.tags!.title.endsWith(suffix) == false) {
        return false;
      }
    }
    return true;
  }

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
