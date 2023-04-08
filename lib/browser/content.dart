import 'package:flutter/cupertino.dart';

import '../model/preferences.dart';
import '../scanner/scanner.dart';

class BrowserContent extends StatefulWidget {
  const BrowserContent({super.key});

  @override
  State<BrowserContent> createState() => _BrowserContentState();
}

class _BrowserContentState extends State<BrowserContent> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => runScan(Preferences.of(context).musicFolder),
      child: const Text('Scan'),
    );
  }
}
