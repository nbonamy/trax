import 'package:flutter/material.dart';

class BrowserSidebar extends StatefulWidget {
  final ScrollController scrollController;
  const BrowserSidebar({super.key, required this.scrollController});

  @override
  State<BrowserSidebar> createState() => _BrowserSidebarState();
}

class _BrowserSidebarState extends State<BrowserSidebar> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
    );
  }
}
