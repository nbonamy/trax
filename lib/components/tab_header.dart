import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import 'trax_colors.dart';

const _kTabBorderRadius = BorderRadius.all(
  Radius.circular(4.0),
);

class MacosTab2 extends MacosTab {
  final double? fontSize;
  const MacosTab2({
    super.key,
    required super.label,
    super.active = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _kTabBorderRadius,
        color: active ? colors.accent : MacosColors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: active ? colors.accentInk : colors.text,
          ),
        ),
      ),
    );
  }

  @override
  MacosTab copyWith({
    String? label,
    bool? active,
  }) {
    return MacosTab2(
      label: label ?? this.label,
      active: active ?? this.active,
      fontSize: fontSize,
    );
  }
}
