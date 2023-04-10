import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StatusBarWidget extends StatelessWidget {
  final String message;
  const StatusBarWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

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
              message,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.black.withOpacity(0.8),
                size: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
