import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StatusBarWidget extends StatefulWidget {
  final String message;
  final Function? onStop;
  const StatusBarWidget({
    Key? key,
    required this.message,
    required this.onStop,
  }) : super(key: key);

  @override
  State<StatusBarWidget> createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.message,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: _hovered
                    ? GestureDetector(
                        onTap: () => widget.onStop?.call(),
                        child: Icon(
                          CupertinoIcons.stop_circle,
                          color: Colors.black.withOpacity(0.8),
                          size: 12,
                        ),
                      )
                    : LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.black.withOpacity(0.8),
                        size: 12,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
