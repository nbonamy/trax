import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/audioplayer/glass_player.dart';
import 'package:trax/browser/sidebar.dart';
import 'package:trax/components/inspector.dart';
import 'package:trax/components/tidy_panel.dart';
import 'package:trax/model/library_health.dart';
import 'package:trax/model/selection.dart';
import 'package:trax/model/track.dart';
import 'package:trax/utils/events.dart';

import 'test_utils.dart';

Track _track(String title, {String album = 'GUTS', int index = 1}) => Track(
      filename: '/m/$title.flac',
      filesize: 1,
      lastModified: 0,
      format: Format.flac,
      tags: Tags(
        title: title,
        album: album,
        artist: 'Olivia Rodrigo',
        genre: 'Pop',
        year: 2023,
        trackIndex: index,
      ),
    );

void main() {
  group('sidebar', () {
    test('library entries come first, then artists with their letters', () {
      final entries = buildSidebarEntries(
        [
          Track.kArtistCompilations,
          'AC/DC',
          'The Alan Parsons Project',
          '2Pac'
        ],
        libraryLabel: 'Library',
        artistsLabel: 'Artists',
      );
      expect(entries.map((e) => e.header ?? e.artist).toList(), [
        'Library',
        Track.kArtistsHome,
        Track.kArtistCompilations,
        'Artists',
        'AC/DC',
        'The Alan Parsons Project',
        '2Pac',
      ]);
      expect(entries.where((e) => e.isHeader).length, 2);
      expect(entries[4].letter, 'A');
      expect(entries[5].letter, 'A'); // "The" is ignored when filing
      expect(entries[6].letter, '#');
    });

    test('no compilations, no compilations entry', () {
      final entries = buildSidebarEntries(
        ['AC/DC'],
        libraryLabel: 'Library',
        artistsLabel: 'Artists',
      );
      expect(
          entries.any((e) => e.artist == Track.kArtistCompilations), isFalse);
    });
  });

  group('tidy panel', () {
    testWidgets('lists what needs attention and opens its review',
        (tester) async {
      final List<ShowReviewEvent> shown = [];
      final sub = eventBus.on<ShowReviewEvent>().listen(shown.add);
      await tester.pumpWidget(await bootstrapWidget(
        tester,
        const TidyPanel(
          health: LibraryHealth(
            totalTracks: 100,
            mixedGenreAlbums: 1,
            noYearTracks: 5,
            affectedTracks: 20,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('2 things to tidy'), findsOneWidget);
      expect(find.text('1 album mixes several genres'), findsOneWidget);
      expect(find.text('5 tracks have no year'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Review'), findsNWidgets(2));
      // bitrate is not something to tidy
      expect(find.textContaining('kbps'), findsNothing);

      await tester.tap(find.text('Review').last);
      await tester.pump();
      sub.cancel();
      expect(shown.map((e) => e.kind), [ReviewKind.noYear]);
    });

    testWidgets('a tidy library says so', (tester) async {
      await tester.pumpWidget(await bootstrapWidget(
        tester,
        const TidyPanel(health: LibraryHealth(totalTracks: 10)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Everything is in order'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Review'), findsNothing);
    });
  });

  group('inspector', () {
    testWidgets('stays closed with no selection', (tester) async {
      await tester.pumpWidget(
        await bootstrapWidget(
          tester,
          const Align(
            alignment: Alignment.topLeft,
            child: InspectorPanel(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(InspectorPanel)).width, 0);
      expect(find.text('Edit Tags…'), findsNothing);
    });

    testWidgets('shared values show, differing ones are Mixed', (tester) async {
      await tester.pumpWidget(
        await bootstrapWidget(
          tester,
          const Align(
            alignment: Alignment.topLeft,
            child: InspectorPanel(),
          ),
        ),
      );
      final SelectionModel selection =
          SelectionModel.of(tester.element(find.byType(InspectorPanel)));
      selection.set([
        _track('vampire', album: 'GUTS', index: 3),
        _track('good 4 u', album: 'SOUR', index: 5),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('2 tracks selected'), findsOneWidget);
      expect(find.text('Olivia Rodrigo'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);
      // title, album and track number differ; no single cover fits
      expect(find.text('Mixed'), findsNWidgets(3));
      expect(find.text('Mixed artwork'), findsOneWidget);
      expect(find.text('Edit Tags…'), findsOneWidget);
      expect(find.text('Cleanup Titles'), findsOneWidget);
    });
  });

  group('glass player bar', () {
    testWidgets('is hidden and inert until something is queued',
        (tester) async {
      await tester.pumpWidget(
        await bootstrapWidget(tester, const GlassPlayerBar()),
      );
      await tester.pumpAndSettle();
      final IgnorePointer ignore = tester.widget(find
          .descendant(
            of: find.byType(GlassPlayerBar),
            matching: find.byType(IgnorePointer),
          )
          .first);
      expect(ignore.ignoring, isTrue);
      final AnimatedOpacity opacity = tester.widget(find
          .descendant(
            of: find.byType(GlassPlayerBar),
            matching: find.byType(AnimatedOpacity),
          )
          .first);
      expect(opacity.opacity, 0);
    });
  });
}
