import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'content.dart';
import 'sidebar.dart';

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => BrowserWidgetState();
}

class BrowserWidgetState extends State<BrowserWidget> {
  BuildContext? _navigatorContext;
  @override
  Widget build(BuildContext context) {
    Widget window = MacosWindow(
      sidebar: Sidebar(
        minWidth: 250,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(210, 207, 202, 1.0),
        ),
        builder: (context, controller) {
          return BrowserSidebar(
            scrollController: controller,
          );
        },
      ),
      child: CupertinoTabView(builder: (context) {
        _navigatorContext = context;
        return const BrowserContent();
      }),
    );

    return window;
  }
}
