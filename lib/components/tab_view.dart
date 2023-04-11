import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'tab_header.dart';

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
    return MacosTabView(
      padding: padding,
      controller: controller,
      tabs: labels
          .map(
            (l) => MacosTab2(
              label: l,
              fontSize: 13.0,
            ),
          )
          .toList(),
      children: children
          .map(
            (w) => Container(
              color: CupertinoColors.white,
              child: w,
            ),
          )
          .toList(),
    );
  }
}
