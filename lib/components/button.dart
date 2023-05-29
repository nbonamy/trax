import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double verticalPadding;
  final double? horizontalPadding;
  final bool defaultButton;
  final bool noBorder;
  const Button(
    this.label, {
    super.key,
    required this.onPressed,
    this.verticalPadding = 3,
    this.horizontalPadding,
    this.defaultButton = false,
    this.noBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    PushButton button = PushButton(
      buttonSize: ButtonSize.large,
      padding: EdgeInsets.only(
        top: verticalPadding,
        bottom: verticalPadding + 2,
        left: horizontalPadding ?? (noBorder ? 0 : 24),
        right: horizontalPadding ?? (noBorder ? 0 : 24),
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
