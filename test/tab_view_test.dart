import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:trax/components/tab_view.dart';

void main() {
  testWidgets('shows the selected page and follows the controller',
      (tester) async {
    final MacosTabController controller =
        MacosTabController(initialIndex: 0, length: 2);
    await tester.pumpWidget(MacosApp(
      theme: MacosThemeData.light(),
      home: SizedBox(
        width: 400,
        height: 300,
        child: TabView(
          controller: controller,
          labels: const ['Details', 'Artwork'],
          children: const [Text('first page'), Text('second page')],
        ),
      ),
    ));
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Artwork'), findsOneWidget);
    expect(find.text('first page'), findsOneWidget);
    expect(find.text('second page'), findsNothing);

    controller.index = 1;
    await tester.pump();
    expect(find.text('second page'), findsOneWidget);
    expect(find.text('first page'), findsNothing);
  });

  testWidgets('does not paint the library solid grey behind the page',
      (tester) async {
    await tester.pumpWidget(MacosApp(
      theme: MacosThemeData.light(),
      home: SizedBox(
        width: 400,
        height: 300,
        child: TabView(
          controller: MacosTabController(length: 2),
          labels: const ['a', 'b'],
          children: const [SizedBox(), SizedBox()],
        ),
      ),
    ));
    final Iterable<BoxDecoration> fills = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>();
    const grey = [Color(0xFFE6E9EA), Color(0xFF2B2E33)];
    expect(fills.where((d) => grey.contains(d.color)), isEmpty);
  });
}
