import 'package:flutter/material.dart';
import 'package:trax/model/preferences.dart';

class DraggableCard extends StatefulWidget {
  final Widget child;
  final String? preferenceKey;
  const DraggableCard({
    Key? key,
    required this.child,
    this.preferenceKey,
  }) : super(key: key);

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
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
          details.delta.dx / (size.width / 4),
          details.delta.dy / (size.height / 4),
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
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
