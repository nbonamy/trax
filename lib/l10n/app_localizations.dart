import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse…'**
  String get browse;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'An error occured while updating metadata.'**
  String get saveError;

  /// No description provided for @scanRunningError.
  ///
  /// In en, this message translates to:
  /// **'A scan is already in progress.'**
  String get scanRunningError;

  /// No description provided for @cleanupTitleError.
  ///
  /// In en, this message translates to:
  /// **'No common suffix in selected tracks titles'**
  String get cleanupTitleError;

  /// No description provided for @menuAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings…'**
  String get menuAppSettings;

  /// No description provided for @menuFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// No description provided for @menuFileImport.
  ///
  /// In en, this message translates to:
  /// **'Add to Library…'**
  String get menuFileImport;

  /// No description provided for @menuFileRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get menuFileRefresh;

  /// No description provided for @menuFileRebuild.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get menuFileRebuild;

  /// No description provided for @menuFileReveal.
  ///
  /// In en, this message translates to:
  /// **'Show in Finder'**
  String get menuFileReveal;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuEditSelectAllAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select All Album Tracks'**
  String get menuEditSelectAllAlbum;

  /// No description provided for @menuEditSelectAllArtist.
  ///
  /// In en, this message translates to:
  /// **'Select All Artist Tracks'**
  String get menuEditSelectAllArtist;

  /// No description provided for @menuEditCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get menuEditCopy;

  /// No description provided for @menuEditPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get menuEditPaste;

  /// No description provided for @menuEditDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuEditDelete;

  /// No description provided for @menuEditDeleteSoft.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get menuEditDeleteSoft;

  /// No description provided for @menuTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get menuTrack;

  /// No description provided for @menuTrackInfo.
  ///
  /// In en, this message translates to:
  /// **'Info…'**
  String get menuTrackInfo;

  /// No description provided for @menuTrackCleanupTitles.
  ///
  /// In en, this message translates to:
  /// **'Cleanup Titles'**
  String get menuTrackCleanupTitles;

  /// No description provided for @menuTrackTranscode.
  ///
  /// In en, this message translates to:
  /// **'Convert…'**
  String get menuTrackTranscode;

  /// No description provided for @menuTrackPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get menuTrackPlay;

  /// No description provided for @menuTrackPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous track'**
  String get menuTrackPrev;

  /// No description provided for @menuTrackNext.
  ///
  /// In en, this message translates to:
  /// **'Next track'**
  String get menuTrackNext;

  /// No description provided for @menuTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get menuTools;

  /// No description provided for @menuToolsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit tags in files…'**
  String get menuToolsEdit;

  /// No description provided for @menuToolsTranscode.
  ///
  /// In en, this message translates to:
  /// **'Convert audio format…'**
  String get menuToolsTranscode;

  /// No description provided for @menuView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuView;

  /// No description provided for @menuWindow.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get menuWindow;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuHelp;

  /// No description provided for @deleteTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteTitleSingle(Object name);

  /// No description provided for @deleteTitleMultiple.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the {count} selected items?'**
  String deleteTitleMultiple(Object count);

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'{count,plural ,=1{This item} other{{count} items}} will be moved to the Trash and can be recovered from there.'**
  String deleteText(num count);

  /// No description provided for @rebuildConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to rebuild your entire library?'**
  String get rebuildConfirm;

  /// No description provided for @overwriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Destination file(s) already exists. Do you want to overwrite them?'**
  String get overwriteConfirm;

  /// No description provided for @scanInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning audio files'**
  String get scanInProgress;

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Parsing imported files'**
  String get importInProgress;

  /// No description provided for @saveInProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving files'**
  String get saveInProgress;

  /// No description provided for @transcodeInProgress.
  ///
  /// In en, this message translates to:
  /// **'Converting audio files ({index} of {count})'**
  String transcodeInProgress(Object count, Object index);

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get unknownTitle;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get unknownAlbum;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @unknownGenre.
  ///
  /// In en, this message translates to:
  /// **'Unknown genre'**
  String get unknownGenre;

  /// No description provided for @variousFormats.
  ///
  /// In en, this message translates to:
  /// **'Various Formats'**
  String get variousFormats;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @compilations.
  ///
  /// In en, this message translates to:
  /// **'Compilations'**
  String get compilations;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @welcomeLibraryLocation.
  ///
  /// In en, this message translates to:
  /// **'You Music folder is currently set to: '**
  String get welcomeLibraryLocation;

  /// No description provided for @welcomeActionsIntro.
  ///
  /// In en, this message translates to:
  /// **'You can '**
  String get welcomeActionsIntro;

  /// No description provided for @welcomeActionChange.
  ///
  /// In en, this message translates to:
  /// **'change it'**
  String get welcomeActionChange;

  /// No description provided for @welcomeActionsOr.
  ///
  /// In en, this message translates to:
  /// **' or '**
  String get welcomeActionsOr;

  /// No description provided for @welcomeActionScan.
  ///
  /// In en, this message translates to:
  /// **'run a scan'**
  String get welcomeActionScan;

  /// No description provided for @welcomeActionsEnd.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get welcomeActionsEnd;

  /// No description provided for @startLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your Library'**
  String get startLibrary;

  /// No description provided for @addedRecently.
  ///
  /// In en, this message translates to:
  /// **'Added recently'**
  String get addedRecently;

  /// No description provided for @statsTracks.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks'**
  String statsTracks(Object count);

  /// No description provided for @statsArtists.
  ///
  /// In en, this message translates to:
  /// **'{count} artists'**
  String statsArtists(Object count);

  /// No description provided for @statsAlbums.
  ///
  /// In en, this message translates to:
  /// **'{count} albums'**
  String statsAlbums(Object count);

  /// No description provided for @statsDurationHours.
  ///
  /// In en, this message translates to:
  /// **' hours '**
  String get statsDurationHours;

  /// No description provided for @statsDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **' minutes '**
  String get statsDurationMinutes;

  /// No description provided for @sidebarLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get sidebarLibrary;

  /// No description provided for @sidebarArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get sidebarArtists;

  /// No description provided for @startSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{tracks} · {duration} · {artists} · {albums}'**
  String startSubtitle(
      Object tracks, Object duration, Object artists, Object albums);

  /// No description provided for @dropTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop music here'**
  String get dropTitle;

  /// No description provided for @dropDescription.
  ///
  /// In en, this message translates to:
  /// **'MP3, FLAC and M4A, files or whole folders. Trax reads the tags, fills gaps from file names and files everything in your Music folder.'**
  String get dropDescription;

  /// No description provided for @dropOnImport.
  ///
  /// In en, this message translates to:
  /// **'On import'**
  String get dropOnImport;

  /// No description provided for @tidyLabel.
  ///
  /// In en, this message translates to:
  /// **'tidy'**
  String get tidyLabel;

  /// No description provided for @tidyAllGood.
  ///
  /// In en, this message translates to:
  /// **'Everything is in order'**
  String get tidyAllGood;

  /// No description provided for @tidyAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get tidyAllDone;

  /// No description provided for @tidyIssues.
  ///
  /// In en, this message translates to:
  /// **'{count,plural ,=1{One thing to tidy} other{{count} things to tidy}}'**
  String tidyIssues(int count);

  /// No description provided for @tidyMixedGenres.
  ///
  /// In en, this message translates to:
  /// **'{count,plural ,=1{1 album mixes} other{{count} albums mix}} several genres'**
  String tidyMixedGenres(int count);

  /// No description provided for @tidyNoYear.
  ///
  /// In en, this message translates to:
  /// **'{count,plural ,=1{1 track has} other{{count} tracks have}} no year'**
  String tidyNoYear(int count);

  /// No description provided for @tidyReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get tidyReview;

  /// No description provided for @recentLossless.
  ///
  /// In en, this message translates to:
  /// **'lossless'**
  String get recentLossless;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results for “{query}”'**
  String searchResultsTitle(Object query);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No tracks match “{query}”.'**
  String searchNoResults(Object query);

  /// No description provided for @reviewMixedGenresTitle.
  ///
  /// In en, this message translates to:
  /// **'Albums with several genres'**
  String get reviewMixedGenresTitle;

  /// No description provided for @reviewNoYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracks without a year'**
  String get reviewNoYearTitle;

  /// No description provided for @reviewMixedGenresHint.
  ///
  /// In en, this message translates to:
  /// **'Open a track\'s tags to give every track of an album the same genre.'**
  String get reviewMixedGenresHint;

  /// No description provided for @reviewNoYearHint.
  ///
  /// In en, this message translates to:
  /// **'Select tracks and edit their tags to set the year.'**
  String get reviewNoYearHint;

  /// No description provided for @trackColumnGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get trackColumnGenre;

  /// No description provided for @trackColumnYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get trackColumnYear;

  /// No description provided for @albumsAndSongs.
  ///
  /// In en, this message translates to:
  /// **'{albums,plural ,=1{1 album} other{{albums} albums}}, {songs,plural ,=1{1 song} other{{songs} songs}}'**
  String albumsAndSongs(int albums, int songs);

  /// No description provided for @trackColumnTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get trackColumnTitle;

  /// No description provided for @trackColumnFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get trackColumnFormat;

  /// No description provided for @trackColumnTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get trackColumnTime;

  /// No description provided for @inspectorNone.
  ///
  /// In en, this message translates to:
  /// **'Select one or more tracks to see and edit their tags.'**
  String get inspectorNone;

  /// No description provided for @inspectorSelected.
  ///
  /// In en, this message translates to:
  /// **'{count,plural ,=1{1 track selected} other{{count} tracks selected}}'**
  String inspectorSelected(int count);

  /// No description provided for @inspectorEditTags.
  ///
  /// In en, this message translates to:
  /// **'Edit Tags…'**
  String get inspectorEditTags;

  /// No description provided for @inspectorMixedArtwork.
  ///
  /// In en, this message translates to:
  /// **'Mixed artwork'**
  String get inspectorMixedArtwork;

  /// No description provided for @editorDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get editorDetails;

  /// No description provided for @editorArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get editorArtwork;

  /// No description provided for @editorLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get editorLyrics;

  /// No description provided for @editorFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get editorFile;

  /// No description provided for @tagTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get tagTitle;

  /// No description provided for @tagAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get tagAlbum;

  /// No description provided for @tagArtist.
  ///
  /// In en, this message translates to:
  /// **'Album artist'**
  String get tagArtist;

  /// No description provided for @tagPerformer.
  ///
  /// In en, this message translates to:
  /// **'Performer'**
  String get tagPerformer;

  /// No description provided for @tagComposer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get tagComposer;

  /// No description provided for @tagGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get tagGenre;

  /// No description provided for @tagYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get tagYear;

  /// No description provided for @tagVolumeIndex.
  ///
  /// In en, this message translates to:
  /// **'Disc number'**
  String get tagVolumeIndex;

  /// No description provided for @tagTrackIndex.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get tagTrackIndex;

  /// No description provided for @tagCompilation.
  ///
  /// In en, this message translates to:
  /// **'Compilation'**
  String get tagCompilation;

  /// No description provided for @tagCompilationDesc.
  ///
  /// In en, this message translates to:
  /// **'Album is a compilation of songs by various artists'**
  String get tagCompilationDesc;

  /// No description provided for @tagCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get tagCopyright;

  /// No description provided for @tagComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get tagComment;

  /// No description provided for @tagsMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get tagsMixed;

  /// No description provided for @indexOfCount.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get indexOfCount;

  /// No description provided for @fileInfoKind.
  ///
  /// In en, this message translates to:
  /// **'kind'**
  String get fileInfoKind;

  /// No description provided for @fileInfoDuration.
  ///
  /// In en, this message translates to:
  /// **'duration'**
  String get fileInfoDuration;

  /// No description provided for @fileInfoFileSize.
  ///
  /// In en, this message translates to:
  /// **'size'**
  String get fileInfoFileSize;

  /// No description provided for @fileInfoBitsPerSample.
  ///
  /// In en, this message translates to:
  /// **'bits per sample'**
  String get fileInfoBitsPerSample;

  /// No description provided for @fileInfoSampleRate.
  ///
  /// In en, this message translates to:
  /// **'sample rate'**
  String get fileInfoSampleRate;

  /// No description provided for @fileInfoBitrate.
  ///
  /// In en, this message translates to:
  /// **'bitrate'**
  String get fileInfoBitrate;

  /// No description provided for @fileInfoChannels.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get fileInfoChannels;

  /// No description provided for @fileInfoImported.
  ///
  /// In en, this message translates to:
  /// **'date imported'**
  String get fileInfoImported;

  /// No description provided for @fileInfoModified.
  ///
  /// In en, this message translates to:
  /// **'date modified'**
  String get fileInfoModified;

  /// No description provided for @fileInfoFilePath.
  ///
  /// In en, this message translates to:
  /// **'location'**
  String get fileInfoFilePath;

  /// No description provided for @artworkDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get artworkDelete;

  /// No description provided for @artworkUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update…'**
  String get artworkUpdate;

  /// No description provided for @lyricsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete lyrics from all tracks'**
  String get lyricsDelete;

  /// No description provided for @importFileOpCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get importFileOpCopy;

  /// No description provided for @importFileOpMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get importFileOpMove;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsMusicFolder.
  ///
  /// In en, this message translates to:
  /// **'Music Folder'**
  String get settingsMusicFolder;

  /// No description provided for @settingsImportOptions.
  ///
  /// In en, this message translates to:
  /// **'Import Options'**
  String get settingsImportOptions;

  /// No description provided for @settingsImportFileOpDesc.
  ///
  /// In en, this message translates to:
  /// **'files to Music folder when adding to Library'**
  String get settingsImportFileOpDesc;

  /// No description provided for @settingsKeepOrganizedDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep Music Media folder organized'**
  String get settingsKeepOrganizedDesc;

  /// No description provided for @settingsLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Options'**
  String get settingsLyrics;

  /// No description provided for @settingsLyricsSaveMode.
  ///
  /// In en, this message translates to:
  /// **'Save lyrics in'**
  String get settingsLyricsSaveMode;

  /// No description provided for @settingsLyricsSaveModeTags.
  ///
  /// In en, this message translates to:
  /// **'Audio file tags'**
  String get settingsLyricsSaveModeTags;

  /// No description provided for @settingsLyricsSaveModeLrc.
  ///
  /// In en, this message translates to:
  /// **'Companion LRC file'**
  String get settingsLyricsSaveModeLrc;

  /// No description provided for @transcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Conversion'**
  String get transcodeTitle;

  /// No description provided for @transcodeDestination.
  ///
  /// In en, this message translates to:
  /// **'Target Folder'**
  String get transcodeDestination;

  /// No description provided for @transcodeDestinationSame.
  ///
  /// In en, this message translates to:
  /// **'Same as source file'**
  String get transcodeDestinationSame;

  /// No description provided for @transcodeDeleteSrc.
  ///
  /// In en, this message translates to:
  /// **'Delete source files'**
  String get transcodeDeleteSrc;

  /// No description provided for @transcodeFormat.
  ///
  /// In en, this message translates to:
  /// **'Target Format'**
  String get transcodeFormat;

  /// No description provided for @transcodeBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get transcodeBitrate;

  /// No description provided for @transcodeSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample Rate'**
  String get transcodeSampleRate;

  /// No description provided for @transcodeBitsPerSample.
  ///
  /// In en, this message translates to:
  /// **'Bits Per Sample'**
  String get transcodeBitsPerSample;

  /// No description provided for @transcodeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Source Info'**
  String get transcodeInfoTitle;

  /// No description provided for @transcodeInfoVariousFormats.
  ///
  /// In en, this message translates to:
  /// **'various formats'**
  String get transcodeInfoVariousFormats;

  /// No description provided for @transcodeInfoVariousBitrates.
  ///
  /// In en, this message translates to:
  /// **'various bitrates'**
  String get transcodeInfoVariousBitrates;

  /// No description provided for @transcodeInfoVariousSampleRates.
  ///
  /// In en, this message translates to:
  /// **'various sample rates'**
  String get transcodeInfoVariousSampleRates;

  /// No description provided for @transcodeInfoVariousBitsPerSample.
  ///
  /// In en, this message translates to:
  /// **'various bits per sample'**
  String get transcodeInfoVariousBitsPerSample;

  /// No description provided for @cleanupTitleCommentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title notes like \"(Remastered 2023)\" will be moved to comments. Continue?'**
  String get cleanupTitleCommentsEmpty;

  /// No description provided for @cleanupTitleCommentsNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title notes like \"(Remastered 2023)\" will overwrite current comments. Continue?'**
  String get cleanupTitleCommentsNotEmpty;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Trax'**
  String get appName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
