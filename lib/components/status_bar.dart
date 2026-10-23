import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'trax_colors.dart';

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
    final TraxColors colors = TraxColors.of(context);
    return Column(
      children: [
        Divider(color: colors.line),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.message,
              style: TextStyle(fontSize: 12, color: colors.text),
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
                          color: colors.soft,
                          size: 12,
                        ),
                      )
                    : LoadingAnimationWidget.staggeredDotsWave(
                        color: colors.soft,
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
