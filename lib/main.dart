import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'audioplayer/audio_player.dart';
import 'components/theme.dart';
import 'data/database.dart';
import 'model/preferences.dart';
import 'model/selection.dart';
import 'processors/http.dart';
import 'screens/home.dart';
import 'utils/artwork_provider.dart';
import 'utils/consts.dart';
import 'utils/logger.dart';
import 'utils/track_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // logger
  Logger logger = Logger();

  // load some stuff
  TraxDatabase traxDatabase = TraxDatabase(logger: logger);
  Preferences preferences = Preferences();
  await preferences.init();
  await traxDatabase.init();

  // other stuff
  ArtworkProvider artworkProvider = ArtworkProvider();

  // and a server
  TraxServer server = TraxServer(logger, traxDatabase, artworkProvider);
  server.start();

  // audio service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.nabocorp.trax',
    androidNotificationChannelName: 'Trax Audio Playback',
    androidNotificationOngoing: true,
  );

  // default options
  WindowOptions windowOptions = const WindowOptions(
    //size: rc.size,
    //center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // run
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    Rect rc = preferences.windowBounds;
    await windowManager.setBackgroundColor(Colors.white);
    await windowManager.setBounds(rc);
    await windowManager.show();
    await windowManager.focus();

    runApp(TraxApp(
      logger: logger,
      preferences: preferences,
      database: traxDatabase,
      artworkProvider: artworkProvider,
    ));
  });
}

class TraxApp extends StatelessWidget {
  final Logger logger;
  final Preferences preferences;
  final TraxDatabase database;
  final ArtworkProvider artworkProvider;
  const TraxApp({
    super.key,
    required this.logger,
    required this.preferences,
    required this.database,
    required this.artworkProvider,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppTheme(),
        ),
        ChangeNotifierProvider(
          create: (_) => logger,
        ),
        ChangeNotifierProvider(
          create: (_) => preferences,
        ),
        ChangeNotifierProvider(
          create: (_) => database,
        ),
        ChangeNotifierProvider(
          create: (_) => SelectionModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => artworkProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => AudioPlayer(),
        ),
      ],
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return MacosApp(
          onGenerateTitle: (context) {
            AppLocalizations? t = AppLocalizations.of(context);
            TrackUtils.initLocalization(t);
            return t?.appName ?? Consts.appName;
          },
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: Colors.white,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('fr', ''),
          ],
          home: const TraxHomePage(),
        );
      },
    );
  }
}
