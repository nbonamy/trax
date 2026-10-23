import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:macos_ui/macos_ui.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/audioplayer/glass_player.dart';
import 'package:trax/audioplayer/player_math.dart';
import 'package:trax/components/glass.dart';
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
