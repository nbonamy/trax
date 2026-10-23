// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get clear => 'Effacer';

  @override
  String get browse => 'Parcourir…';

  @override
  String get saveError => 'Une erreur est survenue lors de la sauvegarde.';

  @override
  String get scanRunningError => 'Une analyse est déjà en cours.';

  @override
  String get cleanupTitleError =>
      'Pas de suffixe commun trouvé dans les pistes sélectionnées.';

  @override
  String get menuAppSettings => 'Configuration…';

  @override
  String get menuFile => 'Fichier';

  @override
  String get menuFileImport => 'Ajouter à la librairie…';

  @override
  String get menuFileRefresh => 'Rafraîchir';

  @override
  String get menuFileRebuild => 'Reconstruire';

  @override
  String get menuFileReveal => 'Révéler dans Finder';

  @override
  String get menuEdit => 'Edition';

  @override
  String get menuEditSelectAllAlbum =>
      'Sélectionner toutes les pistes de l\'album';

  @override
  String get menuEditSelectAllArtist =>
      'Sélectionner toutes les pistes de l\'artist';

  @override
  String get menuEditCopy => 'Copier';

  @override
  String get menuEditPaste => 'Coller';

  @override
  String get menuEditDelete => 'Supprimer';

  @override
  String get menuEditDeleteSoft => 'Déplacer dans la Corbeille';

  @override
  String get menuTrack => 'Piste';

  @override
  String get menuTrackInfo => 'Info…';

  @override
  String get menuTrackCleanupTitles => 'Nettoyer les Titres';

  @override
  String get menuTrackTranscode => 'Convertir…';

  @override
  String get menuTrackPlay => 'Jouer';

  @override
  String get menuTrackPrev => 'Piste précédente';

  @override
  String get menuTrackNext => 'Piste suivante';

  @override
  String get menuTools => 'Outils';

  @override
  String get menuToolsEdit => 'Editer les tags de fichiers…';

  @override
  String get menuToolsTranscode => 'Conversion de format audio…';

  @override
  String get menuView => 'Affichage';

  @override
  String get menuWindow => 'Fenêtres';

  @override
  String get menuHelp => 'Aide';

  @override
  String deleteTitleSingle(Object name) {
    return 'Etes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String deleteTitleMultiple(Object count) {
    return 'Etes-vous sûr de vouloir supprimer les $count éléments sélectionnés ?';
  }

  @override
  String deleteText(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: 'Cet élément',
    );
    return '$_temp0 vont être déplacés dans la Corbeille.';
  }

  @override
  String get rebuildConfirm =>
      'Etes-vous sûr de vouloir reconstruite votre collection ?';

  @override
  String get overwriteConfirm =>
      'Les fichiers existent déjà. Voulez-vous les remplacer ?';

  @override
  String get scanInProgress => 'Analyse en cours';

  @override
  String get importInProgress => 'Analyse en cours';

  @override
  String get saveInProgress => 'Sauvegarde en cours';

  @override
  String transcodeInProgress(Object count, Object index) {
    return 'Conversion en cours ($index de $count)';
  }

  @override
  String get unknownTitle => 'Titre inconnu';

  @override
  String get unknownAlbum => 'Album inconnu';

  @override
  String get unknownArtist => 'Artiste inconnu';

  @override
  String get unknownGenre => 'Genre inconnu';

  @override
  String get variousFormats => 'Formats Mélangés';

  @override
  String get home => 'Accueil';

  @override
  String get back => 'Retour';

  @override
  String get compilations => 'Compilations';

  @override
  String get welcomeTitle => 'Bienvenue !';

  @override
  String get welcomeLibraryLocation => 'Votre répertoire Musique est : ';

  @override
  String get welcomeActionsIntro => 'Vous pouvez ';

  @override
  String get welcomeActionChange => 'le modifier';

  @override
  String get welcomeActionsOr => ' ou ';

  @override
  String get welcomeActionScan => 'lancer une analyse';

  @override
  String get welcomeActionsEnd => '.';

  @override
  String get startLibrary => 'Votre collection';

  @override
  String get addedRecently => 'Ajoutés récemment';

  @override
  String statsTracks(Object count) {
    return '$count pistes';
  }

  @override
  String statsArtists(Object count) {
    return '$count artistes';
  }

  @override
  String statsAlbums(Object count) {
    return '$count albums';
  }

  @override
  String get statsDurationHours => ' heures ';

  @override
  String get statsDurationMinutes => ' minutes ';

  @override
  String get sidebarLibrary => 'Bibliothèque';

  @override
  String get sidebarArtists => 'Artistes';

  @override
  String startSubtitle(
      Object tracks, Object duration, Object artists, Object albums) {
    return '$tracks · $duration · $artists · $albums';
  }

  @override
  String get dropTitle => 'Déposez votre musique ici';

  @override
  String get dropDescription =>
      'MP3, FLAC et M4A, fichiers ou dossiers entiers. Trax lit les tags, complète à partir des noms de fichiers et range tout dans votre dossier Musique.';

  @override
  String get dropOnImport => 'À l\'import';

  @override
  String get tidyLabel => 'en ordre';

  @override
  String get tidyAllGood => 'Tout est en ordre';

  @override
  String get tidyAllDone => 'Terminé';

  @override
  String tidyIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count choses à ranger',
      one: 'Une chose à ranger',
    );
    return '$_temp0';
  }

  @override
  String tidyMixedGenres(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums mélangent',
      one: '1 album mélange',
    );
    return '$_temp0 plusieurs genres';
  }

  @override
  String tidyNoYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistes n\'ont',
      one: '1 piste n\'a',
    );
    return '$_temp0 pas d\'année';
  }

  @override
  String get tidyReview => 'Voir';

  @override
  String get recentLossless => 'sans perte';

  @override
  String searchResultsTitle(Object query) {
    return 'Résultats pour « $query »';
  }

  @override
  String searchNoResults(Object query) {
    return 'Aucune piste ne correspond à « $query ».';
  }

  @override
  String get reviewMixedGenresTitle => 'Albums avec plusieurs genres';

  @override
  String get reviewNoYearTitle => 'Pistes sans année';

  @override
  String get reviewMixedGenresHint =>
      'Modifiez les tags pour donner le même genre à toutes les pistes d\'un album.';

  @override
  String get reviewNoYearHint =>
      'Sélectionnez des pistes et modifiez leurs tags pour définir l\'année.';

  @override
  String get trackColumnGenre => 'Genre';

  @override
  String get trackColumnYear => 'Année';

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
      other: '$songs morceaux',
      one: '1 morceau',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get trackColumnTitle => 'Titre';

  @override
  String get trackColumnFormat => 'Format';

  @override
  String get trackColumnTime => 'Durée';

  @override
  String get inspectorNone =>
      'Sélectionnez des pistes pour voir et modifier leurs tags.';

  @override
  String inspectorSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistes sélectionnées',
      one: '1 piste sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get inspectorEditTags => 'Modifier les tags…';

  @override
  String get inspectorMixedArtwork => 'Pochettes différentes';

  @override
  String get editorDetails => 'Détails';

  @override
  String get editorArtwork => 'Jaquette';

  @override
  String get editorLyrics => 'Paroles';

  @override
  String get editorFile => 'Fichier';

  @override
  String get tagTitle => 'Titre';

  @override
  String get tagAlbum => 'Album';

  @override
  String get tagArtist => 'Artiste';

  @override
  String get tagPerformer => 'Interprète';

  @override
  String get tagComposer => 'Compositeur';

  @override
  String get tagGenre => 'Genre';

  @override
  String get tagYear => 'Année';

  @override
  String get tagVolumeIndex => 'Disque';

  @override
  String get tagTrackIndex => 'Piste';

  @override
  String get tagCompilation => 'Compilation';

  @override
  String get tagCompilationDesc => 'Album de compilation de divers artistes';

  @override
  String get tagCopyright => 'Copyright';

  @override
  String get tagComment => 'Commentaire';

  @override
  String get tagsMixed => 'Multiple';

  @override
  String get indexOfCount => 'sur';

  @override
  String get fileInfoKind => 'type';

  @override
  String get fileInfoDuration => 'durée';

  @override
  String get fileInfoFileSize => 'taille';

  @override
  String get fileInfoBitsPerSample => 'taille d\'échantillions';

  @override
  String get fileInfoSampleRate => 'fréquence d\'échantillionnage';

  @override
  String get fileInfoBitrate => 'bitrate';

  @override
  String get fileInfoChannels => 'nb de canaux';

  @override
  String get fileInfoImported => 'importé le';

  @override
  String get fileInfoModified => 'modifié le';

  @override
  String get fileInfoFilePath => 'fichier';

  @override
  String get artworkDelete => 'Supprimer';

  @override
  String get artworkUpdate => 'Mettre à jour…';

  @override
  String get lyricsDelete => 'Supprimer les paroles de toutes les pistes';

  @override
  String get importFileOpCopy => 'Copier';

  @override
  String get importFileOpMove => 'Déplacer';

  @override
  String get settingsTitle => 'Configuration';

  @override
  String get settingsMusicFolder => 'Dossier Musique';

  @override
  String get settingsImportOptions => 'Options d\'import';

  @override
  String get settingsImportFileOpDesc =>
      'les fichiers lors de l\'ajout dans la Collection';

  @override
  String get settingsKeepOrganizedDesc => 'Garder le dossier Musique organisé';

  @override
  String get settingsLyrics => 'Options lyrics';

  @override
  String get settingsLyricsSaveMode => 'Sauvergarder les lyrics dans';

  @override
  String get settingsLyricsSaveModeTags => 'Metadonnées du fichier audio';

  @override
  String get settingsLyricsSaveModeLrc => 'Fichier LRC adjacent';

  @override
  String get transcodeTitle => 'Conversion Audio';

  @override
  String get transcodeDestination => 'Destination';

  @override
  String get transcodeDestinationSame => 'Identique à la source';

  @override
  String get transcodeDeleteSrc => 'Effacer les fichiers originaux';

  @override
  String get transcodeFormat => 'Format';

  @override
  String get transcodeBitrate => 'Bitrate';

  @override
  String get transcodeSampleRate => 'Sample Rate';

  @override
  String get transcodeBitsPerSample => 'Bits Per Sample';

  @override
  String get transcodeInfoTitle => 'Info sources';

  @override
  String get transcodeInfoVariousFormats => 'formats mélangés';

  @override
  String get transcodeInfoVariousBitrates => 'bitrates variables';

  @override
  String get transcodeInfoVariousSampleRates => 'fréquences variables';

  @override
  String get transcodeInfoVariousBitsPerSample => 'tailles variables';

  @override
  String get cleanupTitleCommentsEmpty =>
      'Les notes de titre comme \"(Remastered 2023)\" vont être déplacées vers les commentaires. Continuer ?';

  @override
  String get cleanupTitleCommentsNotEmpty =>
      'Les notes de titre comme \"(Remastered 2023)\" vont écrasés les commentaires existants. Continuer ?';

  @override
  String get appName => 'Trax';
}
