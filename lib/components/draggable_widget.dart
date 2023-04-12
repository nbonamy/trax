import 'package:flutter/material.dart';
import 'package:trax/model/preferences.dart';

class DraggableWidget extends StatefulWidget {
  final Widget child;
  final String? preferenceKey;
  const DraggableWidget({
    Key? key,
    required this.child,
    this.preferenceKey,
  }) : super(key: key);

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget>
    with SingleTickerProviderStateMixin {
  Alignment _dragAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    if (widget.preferenceKey != null) {
      _dragAlignment =
          Preferences.of(context).getDialogAlignment(widget.preferenceKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanUpdate: (details) => setState(() {
        _dragAlignment += Alignment(
          details.delta.dx / (size.width / 3.15), // should be /2...
          details.delta.dy / (size.height / 3.15), // should be /2...
        );
      }),
      onPanEnd: (details) {
        if (widget.preferenceKey != null) {
          Preferences.of(context)
              .saveEditorAlignment(widget.preferenceKey!, _dragAlignment);
        }
      },
      child: Align(
        alignment: _dragAlignment,
        child: widget.child,
      ),
    );
  }
}
