import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool defaultButton;
  final bool noBorder;
  const Button(
    this.label,
    this.onPressed, {
    super.key,
    this.defaultButton = false,
    this.noBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    PushButton button = PushButton(
      buttonSize: ButtonSize.large,
      padding: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: noBorder ? 0 : 24,
      ),
      color: defaultButton ? null : CupertinoColors.white,
      disabledColor: CupertinoColors.white,
      onPressed: onPressed,
      child: Text(label),
    );
    if (defaultButton || noBorder) {
      return button;
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.lightBackgroundGray),
        ),
        child: button,
      );
    }
  }
}
