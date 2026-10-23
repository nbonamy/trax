import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import 'tab_header.dart';
import 'trax_colors.dart';

/// Tabs over a framed page. Like MacosTabView, but the page stays see-through
/// (a hairline frame and a faint wash) instead of a solid grey slab, so that
/// forms sit directly on the glass of their dialog.
class TabView extends StatelessWidget {
  final MacosTabController controller;
  final List<String> labels;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  const TabView({
    super.key,
    required this.controller,
    required this.labels,
    required this.children,
    this.padding = const EdgeInsets.only(top: 36.0),
  });

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: padding,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.stripe,
              border: Border.all(color: colors.line, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => IndexedStack(
                index: controller.index,
                children: KeyedSubtree.ensureUniqueKeysForList(children),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: MacosSegmentedControl(
            controller: controller,
            tabs:
                labels.map((l) => MacosTab2(label: l, fontSize: 13.0)).toList(),
          ),
        ),
      ],
    );
  }
}
