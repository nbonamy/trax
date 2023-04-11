import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

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
    final brightness = MacosTheme.brightnessOf(context);
    return PhysicalModel(
      color: active ? const Color(0xFF2B2E33) : MacosColors.transparent,
      borderRadius: _kTabBorderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: _kTabBorderRadius,
          color: active
              ? brightness.resolve(
                  MacosColors.white,
                  const Color(0xFF646669),
                )
              : MacosColors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Text(label, style: TextStyle(fontSize: fontSize)),
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
