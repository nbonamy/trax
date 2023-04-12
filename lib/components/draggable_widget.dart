import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DraggableWidget extends StatefulWidget {
  final Widget child;
  final bool alignSelf;
  final Alignment? initialAlign;
  final Function? onAlign;
  const DraggableWidget({
    Key? key,
    required this.child,
    this.alignSelf = true,
    this.initialAlign,
    this.onAlign,
  }) : super(key: key);

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  Alignment _dragAlignment = Alignment.center;
  bool _ignorePan = false;

  @override
  void initState() {
    super.initState();
    _dragAlignment = widget.initialAlign ?? _dragAlignment;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      key: _globalKey,
      behavior: HitTestBehavior.translucent,
      onPanStart: (DragStartDetails details) {
        _ignorePan = false;
        final RenderObject? renderObject =
            _globalKey.currentContext?.findRenderObject();
        final RenderBox? renderBox =
            renderObject is RenderBox ? renderObject : null;
        final hitTestResult = BoxHitTestResult();
        renderBox?.hitTest(hitTestResult,
            position:
                Offset(details.localPosition.dx, details.localPosition.dy));
        bool foundHimself = false;
        for (var entry in hitTestResult.path) {
          if (entry.target is RenderPointerListener) {
            if (foundHimself) {
              _ignorePan = true;
              break;
            } else {
              foundHimself = true;
            }
          }
        }
      },
      onPanUpdate: (details) => setState(() {
        if (_ignorePan) return;
        _dragAlignment += Alignment(
          details.delta.dx / (size.width / 3.15), // should be /2...
          details.delta.dy / (size.height / 3.15), // should be /2...
        );
        widget.onAlign?.call(_dragAlignment);
      }),
      onPanEnd: (details) {
        _ignorePan = false;
      },
      child: widget.alignSelf
          ? Align(
              alignment: _dragAlignment,
              child: widget.child,
            )
          : widget.child,
    );
  }
}
