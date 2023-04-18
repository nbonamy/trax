import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.prograssiveDots(
      size: 64,
      color: CupertinoColors.systemGrey,
    );
  }
}
