import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/audioplayer/glass_player.dart';
import 'package:trax/audioplayer/player_math.dart';
import 'package:trax/components/draggable_dialog.dart';
import 'package:trax/components/glass.dart';
import 'package:trax/utils/system_accessibility.dart';
import 'package:trax/model/track.dart';

Track _track({int duration = 227}) => Track(
      filename: '/Music/Olivia Rodrigo/GUTS/03 - vampire.flac',
      filesize: 1,
      lastModified: 0,
      format: Format.flac,
      tags: Tags(
        title: 'vampire',
        album: 'GUTS',
        artist: 'Olivia Rodrigo',
        performer: 'Olivia Rodrigo',
        duration: duration,
      ),
    );

Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MacosApp(
    debugShowCheckedModeBanner: false,
    theme: MacosThemeData.light(),
    darkTheme: MacosThemeData.dark(),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: Center(child: SizedBox(width: 1000, height: 200, child: child)),
  );
}

GlassPlayerView _view({
  Track? track,
  bool playing = false,
  bool canPrevious = true,
  bool canNext = true,
  bool shuffle = false,
  PlayerRepeat repeat = PlayerRepeat.off,
  double volume = 0.5,
  Stream<double?>? progress,
  VoidCallback? onPlayPause,
  VoidCallback? onPrevious,
  VoidCallback? onNext,
  VoidCallback? onShuffle,
  VoidCallback? onRepeat,
  ValueChanged<double>? onSeek,
  ValueChanged<double>? onVolume,
}) {
  return GlassPlayerView(
    track: track ?? _track(),
    artwork: const SizedBox(),
    playing: playing,
    canPrevious: canPrevious,
    canNext: canNext,
    shuffle: shuffle,
    repeat: repeat,
    volume: volume,
    progress: progress ?? const Stream.empty(),
    onPlayPause: onPlayPause ?? () {},
    onPrevious: onPrevious ?? () {},
    onNext: onNext ?? () {},
    onShuffle: onShuffle ?? () {},
    onRepeat: onRepeat ?? () {},
    onSeek: onSeek ?? (_) {},
    onVolume: onVolume ?? (_) {},
  );
}

void main() {
  group('player math', () {
    test('formatClock', () {
      expect(formatClock(0), '0:00');
      expect(formatClock(3), '0:03');
      expect(formatClock(227), '3:47');
      expect(formatClock(3725), '1:02:05');
      expect(formatClock(-5), '0:00');
    });

    test('fractionForDx clamps to the bar', () {
      expect(fractionForDx(50, 200), 0.25);
      expect(fractionForDx(-10, 200), 0);
      expect(fractionForDx(500, 200), 1);
      expect(fractionForDx(10, 0), 0);
    });

    test('repeat cycles off, all, one', () {
      expect(PlayerRepeat.off.next, PlayerRepeat.all);
      expect(PlayerRepeat.all.next, PlayerRepeat.one);
      expect(PlayerRepeat.one.next, PlayerRepeat.off);
    });

    test('volume icon follows the level', () {
      expect(volumeIcon(0), CupertinoIcons.speaker_slash_fill);
      expect(volumeIcon(0.2), CupertinoIcons.speaker_1_fill);
      expect(volumeIcon(0.5), CupertinoIcons.speaker_2_fill);
      expect(volumeIcon(1), CupertinoIcons.speaker_3_fill);
    });
  });

  group('glass surface', () {
    testWidgets('blurs what is behind it and shows its child', (tester) async {
      await tester.pumpWidget(_host(
        const GlassSurface(radius: 20, child: Text('hello')),
      ));
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('actually paints its tint (a gradient box ignores its color)',
        (tester) async {
      const Color tint = Color(0x80FF0000);
      await tester.pumpWidget(_host(
        const GlassSurface(
          radius: 20,
          style: GlassStyle(
            tint: tint,
            gloss: Color(0x40FFFFFF),
            edgeTop: Color(0xFFFFFFFF),
            edgeBottom: Color(0xFFFFFFFF),
            shadow: Color(0x00000000),
            solid: Color(0xFFFFFFFF),
            contrastEdge: Color(0xFF000000),
          ),
          child: Text('hello'),
        ),
      ));
      final Iterable<BoxDecoration> boxes = tester
          .widgetList<DecoratedBox>(find.descendant(
            of: find.byType(GlassSurface),
            matching: find.byType(DecoratedBox),
          ))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>();
      // the tint is drawn by a box of its own...
      expect(boxes.where((d) => d.color == tint && d.gradient == null),
          hasLength(1));
      // ...and no box carries both: Flutter would drop the color
      expect(
          boxes.where((d) => d.color != null && d.gradient != null), isEmpty);
    });

    testWidgets('picks the style from the theme brightness', (tester) async {
      late Brightness seen;
      await tester.pumpWidget(_host(
        Builder(builder: (context) {
          seen = glassBrightness(context);
          return const SizedBox();
        }),
        brightness: Brightness.dark,
      ));
      expect(seen, Brightness.dark);
      expect(
        GlassStyle.forBrightness(Brightness.dark).tint,
        isNot(GlassStyle.forBrightness(Brightness.light).tint),
      );
    });
  });

  group('system accessibility', () {
    tearDown(() => SystemAccessibility.instance.set(
          reduceTransparency: false,
          increaseContrast: false,
        ));

    testWidgets('reduce transparency turns glass into a plain surface',
        (tester) async {
      await tester.pumpWidget(_host(
        const GlassSurface(radius: 20, child: Text('hello')),
      ));
      expect(find.byType(BackdropFilter), findsOneWidget);

      SystemAccessibility.instance.set(reduceTransparency: true);
      await tester.pump();
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('hello'), findsOneWidget);

      // and back, live, when the setting is switched off again
      SystemAccessibility.instance.set(reduceTransparency: false);
      await tester.pump();
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('increase contrast keeps the glass but sharpens its edge',
        (tester) async {
      await tester.pumpWidget(_host(
        const GlassSurface(radius: 20, child: Text('hello')),
      ));
      SystemAccessibility.instance.set(increaseContrast: true);
      await tester.pump();
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    test('only notifies when something changed', () {
      final system = SystemAccessibility();
      int calls = 0;
      system.addListener(() => calls++);
      system.set(reduceTransparency: true);
      system.set(reduceTransparency: true);
      system.set(increaseContrast: true);
      expect(calls, 2);
      expect(system.reduceTransparency, isTrue);
      expect(system.increaseContrast, isTrue);
    });

    test('translucent panels are tinted more than the player', () {
      expect(
        GlassStyle.panelLight.tint.a,
        greaterThan(GlassStyle.light.tint.a),
      );
      expect(
        GlassStyle.panelDark.tint.a,
        greaterThan(GlassStyle.dark.tint.a),
      );
    });
  });

  group('dialogs', () {
    testWidgets('are glass, so the app shows through them', (tester) async {
      await tester.pumpWidget(_host(
        const DraggableDialog(
          width: 400,
          height: 300,
          header: Text('header'),
          body: Text('body'),
          footer: Text('footer'),
        ),
      ));
      expect(find.byType(GlassSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('header'), findsOneWidget);
      expect(find.text('footer'), findsOneWidget);
    });

    testWidgets('are solid when transparency is reduced', (tester) async {
      SystemAccessibility.instance.set(reduceTransparency: true);
      addTearDown(() => SystemAccessibility.instance.set(
            reduceTransparency: false,
          ));
      await tester.pumpWidget(_host(
        const DraggableDialog(
          width: 400,
          height: 300,
          header: Text('header'),
          body: Text('body'),
          footer: Text('footer'),
        ),
      ));
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('body'), findsOneWidget);
    });
  });

  group('glass player view', () {
    testWidgets('shows title and artist - album', (tester) async {
      await tester.pumpWidget(_host(_view()));
      expect(find.text('vampire'), findsOneWidget);
      expect(find.text('Olivia Rodrigo — GUTS'), findsOneWidget);
    });

    testWidgets('play/pause button reflects the state and is wired',
        (tester) async {
      int taps = 0;
      await tester.pumpWidget(_host(_view(onPlayPause: () => taps++)));
      expect(find.bySemanticsLabel('Play'), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.play_fill));
      expect(taps, 1);

      await tester.pumpWidget(_host(_view(playing: true)));
      expect(find.bySemanticsLabel('Pause'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.pause_fill), findsOneWidget);
    });

    testWidgets('previous and next are inert when they cannot be used',
        (tester) async {
      int prev = 0, next = 0;
      await tester.pumpWidget(_host(_view(
        canPrevious: false,
        canNext: false,
        onPrevious: () => prev++,
        onNext: () => next++,
      )));
      await tester.tap(find.byIcon(CupertinoIcons.backward_fill));
      await tester.tap(find.byIcon(CupertinoIcons.forward_fill));
      expect(prev + next, 0);

      await tester.pumpWidget(_host(_view(
        onPrevious: () => prev++,
        onNext: () => next++,
      )));
      await tester.tap(find.byIcon(CupertinoIcons.backward_fill));
      await tester.tap(find.byIcon(CupertinoIcons.forward_fill));
      expect([prev, next], [1, 1]);
    });

    testWidgets('shuffle and repeat fire their callbacks', (tester) async {
      int shuffle = 0, repeat = 0;
      await tester.pumpWidget(_host(_view(
        onShuffle: () => shuffle++,
        onRepeat: () => repeat++,
      )));
      await tester.tap(find.byIcon(CupertinoIcons.shuffle));
      await tester.tap(find.byIcon(CupertinoIcons.repeat));
      expect([shuffle, repeat], [1, 1]);
    });

    testWidgets('repeat one swaps the icon', (tester) async {
      await tester.pumpWidget(_host(_view(repeat: PlayerRepeat.one)));
      expect(find.byIcon(CupertinoIcons.repeat_1), findsOneWidget);
    });

    testWidgets('tapping the scrubber seeks to that fraction', (tester) async {
      double? sought;
      await tester.pumpWidget(_host(_view(onSeek: (v) => sought = v)));
      final Finder bar = find.byType(GestureDetector).evaluate().isEmpty
          ? find.byType(GlassPlayerView)
          : find
              .byWidgetPredicate(
                (w) => w is GestureDetector && w.onHorizontalDragStart != null,
              )
              .first;
      final Rect rect = tester.getRect(bar);
      await tester.tapAt(Offset(rect.left + rect.width * 0.5, rect.center.dy));
      await tester.pumpAndSettle();
      expect(sought, isNotNull);
      expect(sought!, closeTo(0.5, 0.05));
    });

    testWidgets('muting remembers the previous volume', (tester) async {
      final List<double> volumes = [];
      await tester.pumpWidget(_host(_view(volume: 0.6, onVolume: volumes.add)));
      await tester.tap(find.byIcon(CupertinoIcons.speaker_2_fill));
      expect(volumes, [0.0]);

      await tester.pumpWidget(_host(_view(volume: 0, onVolume: volumes.add)));
      await tester.tap(find.byIcon(CupertinoIcons.speaker_slash_fill));
      expect(volumes.last, 0.6);
    });

    testWidgets('drops the secondary controls when narrow', (tester) async {
      tester.view.physicalSize = const Size(520, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MacosApp(
        theme: MacosThemeData.light(),
        home: Align(alignment: Alignment.bottomCenter, child: _view()),
      ));
      expect(find.byIcon(CupertinoIcons.shuffle), findsNothing);
      expect(find.byIcon(CupertinoIcons.speaker_2_fill), findsNothing);
      expect(find.byIcon(CupertinoIcons.play_fill), findsOneWidget);
    });
  });
}
