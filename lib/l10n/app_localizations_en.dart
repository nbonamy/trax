// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get clear => 'Clear';

  @override
  String get browse => 'Browse…';

  @override
  String get saveError => 'An error occured while updating metadata.';

  @override
  String get scanRunningError => 'A scan is already in progress.';

  @override
  String get cleanupTitleError => 'No common suffix in selected tracks titles';

  @override
  String get menuAppSettings => 'Settings…';

  @override
  String get menuFile => 'File';

  @override
  String get menuFileImport => 'Add to Library…';

  @override
  String get menuFileRefresh => 'Refresh';

  @override
  String get menuFileRebuild => 'Rebuild';

  @override
  String get menuFileReveal => 'Show in Finder';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuEditSelectAllAlbum => 'Select All Album Tracks';

  @override
  String get menuEditSelectAllArtist => 'Select All Artist Tracks';

  @override
  String get menuEditCopy => 'Copy';

  @override
  String get menuEditPaste => 'Paste';

  @override
  String get menuEditDelete => 'Delete';

  @override
  String get menuEditDeleteSoft => 'Move to Trash';

  @override
  String get menuTrack => 'Track';

  @override
  String get menuTrackInfo => 'Info…';

  @override
  String get menuTrackCleanupTitles => 'Cleanup Titles';

  @override
  String get menuTrackTranscode => 'Convert…';

  @override
  String get menuTrackPlay => 'Play';

  @override
  String get menuTrackPrev => 'Previous track';

  @override
  String get menuTrackNext => 'Next track';

  @override
  String get menuTools => 'Tools';

  @override
  String get menuToolsEdit => 'Edit tags in files…';

  @override
  String get menuToolsTranscode => 'Convert audio format…';

  @override
  String get menuView => 'View';

  @override
  String get menuWindow => 'Window';

  @override
  String get menuHelp => 'Help';

  @override
  String deleteTitleSingle(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String deleteTitleMultiple(Object count) {
    return 'Are you sure you want to delete the $count selected items?';
  }

  @override
  String deleteText(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: 'This item',
    );
    return '$_temp0 will be moved to the Trash and can be recovered from there.';
  }

  @override
  String get rebuildConfirm =>
      'Are you sure you want to rebuild your entire library?';

  @override
  String get overwriteConfirm =>
      'Destination file(s) already exists. Do you want to overwrite them?';

  @override
  String get scanInProgress => 'Scanning audio files';

  @override
  String get importInProgress => 'Parsing imported files';

  @override
  String get saveInProgress => 'Saving files';

  @override
  String transcodeInProgress(Object count, Object index) {
    return 'Converting audio files ($index of $count)';
  }

  @override
  String get unknownTitle => 'Unknown title';

  @override
  String get unknownAlbum => 'Unknown album';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get unknownGenre => 'Unknown genre';

  @override
  String get variousFormats => 'Various Formats';

  @override
  String get home => 'Home';

  @override
  String get compilations => 'Compilations';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get welcomeLibraryLocation => 'You Music folder is currently set to: ';

  @override
  String get welcomeActionsIntro => 'You can ';

  @override
  String get welcomeActionChange => 'change it';

  @override
  String get welcomeActionsOr => ' or ';

  @override
  String get welcomeActionScan => 'run a scan';

  @override
  String get welcomeActionsEnd => '.';

  @override
  String get startLibrary => 'Your Library';

  @override
  String get addedRecently => 'Added recently';

  @override
  String statsTracks(Object count) {
    return '$count tracks';
  }

  @override
  String statsArtists(Object count) {
    return '$count artists';
  }

  @override
  String statsAlbums(Object count) {
    return '$count albums';
  }

  @override
  String get statsDurationHours => ' hours ';

  @override
  String get statsDurationMinutes => ' minutes ';

  @override
  String get sidebarLibrary => 'Library';

  @override
  String get sidebarArtists => 'Artists';

  @override
  String startSubtitle(
      Object tracks, Object duration, Object artists, Object albums) {
    return '$tracks · $duration · $artists · $albums';
  }

  @override
  String get dropTitle => 'Drop music here';

  @override
  String get dropDescription =>
      'MP3, FLAC and M4A, files or whole folders. Trax reads the tags, fills gaps from file names and files everything in your Music folder.';

  @override
  String get dropOnImport => 'On import';

  @override
  String get tidyLabel => 'tidy';

  @override
  String get tidyAllGood => 'Everything is in order';

  @override
  String tidyIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things to tidy',
      one: 'One thing to tidy',
    );
    return '$_temp0';
  }

  @override
  String tidyMixedGenres(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums mix',
      one: '1 album mixes',
    );
    return '$_temp0 several genres';
  }

  @override
  String tidyNoYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks have',
      one: '1 track has',
    );
    return '$_temp0 no year';
  }

  @override
  String get tidyReview => 'Review';

  @override
  String get recentLossless => 'lossless';

  @override
  String searchResultsTitle(Object query) {
    return 'Results for “$query”';
  }

  @override
  String searchNoResults(Object query) {
    return 'No tracks match “$query”.';
  }

  @override
  String get reviewMixedGenresTitle => 'Albums with several genres';

  @override
  String get reviewNoYearTitle => 'Tracks without a year';

  @override
  String get reviewMixedGenresHint =>
      'Open a track\'s tags to give every track of an album the same genre.';

  @override
  String get reviewNoYearHint =>
      'Select tracks and edit their tags to set the year.';

  @override
  String get trackColumnGenre => 'Genre';

  @override
  String get trackColumnYear => 'Year';

  @override
  String albumsAndSongs(int albums, int songs) {
    String _temp0 = intl.Intl.pluralLogic(
      albums,
      locale: localeName,
      other: '$albums albums',
      one: '1 album',
    );
    String _temp1 = intl.Intl.pluralLogic(
      songs,
      locale: localeName,
      other: '$songs songs',
      one: '1 song',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get trackColumnTitle => 'Title';

  @override
  String get trackColumnFormat => 'Format';

  @override
  String get trackColumnTime => 'Time';

  @override
  String get inspectorNone =>
      'Select one or more tracks to see and edit their tags.';

  @override
  String inspectorSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks selected',
      one: '1 track selected',
    );
    return '$_temp0';
  }

  @override
  String get inspectorEditTags => 'Edit Tags…';

  @override
  String get inspectorMixedArtwork => 'Mixed artwork';

  @override
  String get editorDetails => 'Details';

  @override
  String get editorArtwork => 'Artwork';

  @override
  String get editorLyrics => 'Lyrics';

  @override
  String get editorFile => 'File';

  @override
  String get tagTitle => 'Title';

  @override
  String get tagAlbum => 'Album';

  @override
  String get tagArtist => 'Album artist';

  @override
  String get tagPerformer => 'Performer';

  @override
  String get tagComposer => 'Composer';

  @override
  String get tagGenre => 'Genre';

  @override
  String get tagYear => 'Year';

  @override
  String get tagVolumeIndex => 'Disc number';

  @override
  String get tagTrackIndex => 'Track';

  @override
  String get tagCompilation => 'Compilation';

  @override
  String get tagCompilationDesc =>
      'Album is a compilation of songs by various artists';

  @override
  String get tagCopyright => 'Copyright';

  @override
  String get tagComment => 'Comment';

  @override
  String get tagsMixed => 'Mixed';

  @override
  String get indexOfCount => 'of';

  @override
  String get fileInfoKind => 'kind';

  @override
  String get fileInfoDuration => 'duration';

  @override
  String get fileInfoFileSize => 'size';

  @override
  String get fileInfoBitsPerSample => 'bits per sample';

  @override
  String get fileInfoSampleRate => 'sample rate';

  @override
  String get fileInfoBitrate => 'bitrate';

  @override
  String get fileInfoChannels => 'channels';

  @override
  String get fileInfoImported => 'date imported';

  @override
  String get fileInfoModified => 'date modified';

  @override
  String get fileInfoFilePath => 'location';

  @override
  String get artworkDelete => 'Delete';

  @override
  String get artworkUpdate => 'Update…';

  @override
  String get lyricsDelete => 'Delete lyrics from all tracks';

  @override
  String get importFileOpCopy => 'Copy';

  @override
  String get importFileOpMove => 'Move';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMusicFolder => 'Music Folder';

  @override
  String get settingsImportOptions => 'Import Options';

  @override
  String get settingsImportFileOpDesc =>
      'files to Music folder when adding to Library';

  @override
  String get settingsKeepOrganizedDesc => 'Keep Music Media folder organized';

  @override
  String get settingsLyrics => 'Lyrics Options';

  @override
  String get settingsLyricsSaveMode => 'Save lyrics in';

  @override
  String get settingsLyricsSaveModeTags => 'Audio file tags';

  @override
  String get settingsLyricsSaveModeLrc => 'Companion LRC file';

  @override
  String get transcodeTitle => 'Audio Conversion';

  @override
  String get transcodeDestination => 'Target Folder';

  @override
  String get transcodeDestinationSame => 'Same as source file';

  @override
  String get transcodeDeleteSrc => 'Delete source files';

  @override
  String get transcodeFormat => 'Target Format';

  @override
  String get transcodeBitrate => 'Bitrate';

  @override
  String get transcodeSampleRate => 'Sample Rate';

  @override
  String get transcodeBitsPerSample => 'Bits Per Sample';

  @override
  String get transcodeInfoTitle => 'Source Info';

  @override
  String get transcodeInfoVariousFormats => 'various formats';

  @override
  String get transcodeInfoVariousBitrates => 'various bitrates';

  @override
  String get transcodeInfoVariousSampleRates => 'various sample rates';

  @override
  String get transcodeInfoVariousBitsPerSample => 'various bits per sample';

  @override
  String get cleanupTitleCommentsEmpty =>
      'Title notes like \"(Remastered 2023)\" will be moved to comments. Continue?';

  @override
  String get cleanupTitleCommentsNotEmpty =>
      'Title notes like \"(Remastered 2023)\" will overwrite current comments. Continue?';

  @override
  String get appName => 'Trax';
}
