import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'trax_colors.dart';

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
    final TraxColors colors = TraxColors.of(context);
    PushButton button = PushButton(
      controlSize: ControlSize.large,
      padding: EdgeInsets.only(
        top: verticalPadding,
        bottom: verticalPadding + 2,
        left: horizontalPadding ?? (noBorder ? 0 : 24),
        right: horizontalPadding ?? (noBorder ? 0 : 24),
      ),
      color: defaultButton ? null : colors.field,
      disabledColor: colors.field,
      onPressed: onPressed,
      child: Text(label),
    );
    if (defaultButton || noBorder) {
      return button;
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.line, width: 0.5),
        ),
        child: button,
      );
    }
  }
}
