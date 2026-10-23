import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Colors of the app, for light and dark.
///
/// Neutral text is always neutral: the accent only ever fills a shape
/// (selection, buttons, rings) and is never used for body text.
class TraxColors {
  final Brightness brightness;

  /// content area
  final Color background;

  /// source list
  final Color sidebar;

  /// toolbar, status bar
  final Color bar;

  /// inputs, cards
  final Color field;

  /// recessed areas, segmented controls
  final Color well;
  final Color line;
  final Color text;
  final Color soft;
  final Color muted;
  final Color faint;
  final Color hover;
  final Color stripe;
  final Color accent;
  final Color accentInk;
  final Color accentFill;
  final Color warning;
  final Color shadow;

  const TraxColors._({
    required this.brightness,
    required this.background,
    required this.sidebar,
    required this.bar,
    required this.field,
    required this.well,
    required this.line,
    required this.text,
    required this.soft,
    required this.muted,
    required this.faint,
    required this.hover,
    required this.stripe,
    required this.accent,
    required this.accentInk,
    required this.accentFill,
    required this.warning,
    required this.shadow,
  });

  bool get isDark => brightness == Brightness.dark;

  static const TraxColors light = TraxColors._(
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    sidebar: Color(0xFFEDECEA),
    bar: Color(0xFFF6F5F3),
    field: Color(0xFFFFFFFF),
    well: Color(0xFFE4E2DE),
    line: Color(0xFFDAD8D4),
    text: Color(0xFF1D1D1F),
    soft: Color(0xFF3B3B3F),
    muted: Color(0xFF636366),
    faint: Color(0xFF68686D),
    hover: Color(0x0F000000),
    stripe: Color(0x08000000),
    accent: Color(0xFF0A64D8),
    accentInk: Color(0xFFFFFFFF),
    accentFill: Color(0x2E0A64D8),
    warning: Color(0x47FF9F0A),
    shadow: Color(0x38000000),
  );

  static const TraxColors dark = TraxColors._(
    brightness: Brightness.dark,
    background: Color(0xFF1E1E21),
    sidebar: Color(0xFF2A292D),
    bar: Color(0xFF262528),
    field: Color(0xFF1C1B1E),
    well: Color(0xFF1F1E22),
    line: Color(0xFF3A393E),
    text: Color(0xFFF5F5F7),
    soft: Color(0xFFD1D1D6),
    muted: Color(0xFFA1A1A8),
    faint: Color(0xFF9A9AA1),
    hover: Color(0x14FFFFFF),
    stripe: Color(0x09FFFFFF),
    accent: Color(0xFF609AE6),
    accentInk: Color(0xFF0B1A33),
    accentFill: Color(0x40609AE6),
    warning: Color(0x57FF9F0A),
    shadow: Color(0x80000000),
  );

  static TraxColors forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static TraxColors of(BuildContext context) {
    return forBrightness(
      MacosTheme.maybeOf(context)?.brightness ??
          MediaQuery.maybePlatformBrightnessOf(context) ??
          Brightness.light,
    );
  }
}
