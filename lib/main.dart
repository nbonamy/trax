import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:trax/data/database.dart';
import 'package:trax/screens/home.dart';
import 'package:window_manager/window_manager.dart';

import 'components/theme.dart';
import 'model/preferences.dart';
import 'model/selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    //size: rc.size,
    //center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // load some stuff
  TraxDatabase traxDatabase = TraxDatabase();
  Preferences preferences = Preferences();
  await preferences.init();
  await traxDatabase.init();

  // run
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    Rect rc = preferences.windowBounds;
    await windowManager.setBackgroundColor(Colors.white);
    await windowManager.setBounds(rc);
    await windowManager.show();
    await windowManager.focus();

    runApp(TraxApp(
      preferences: preferences,
      database: traxDatabase,
    ));
  });
}

class TraxApp extends StatelessWidget {
  final Preferences preferences;
  final TraxDatabase database;
  const TraxApp({
    super.key,
    required this.preferences,
    required this.database,
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
          create: (_) => preferences,
        ),
        ChangeNotifierProvider(
          create: (_) => database,
        ),
        ChangeNotifierProvider(
          create: (_) => SelectionModel(),
        )
      ],
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return MacosApp(
          title: 'Trax',
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
