import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

/// Colors and blur strength of a [GlassSurface].
class GlassStyle {
  final Color tint;
  final Color gloss;
  final Color edgeTop;
  final Color edgeBottom;
  final Color shadow;
  final double blur;

  const GlassStyle({
    required this.tint,
    required this.gloss,
    required this.edgeTop,
    required this.edgeBottom,
    required this.shadow,
    this.blur = 30,
  });

  static const GlassStyle light = GlassStyle(
    tint: Color(0x85FFFFFF),
    gloss: Color(0x8CFFFFFF),
    edgeTop: Color(0xF2FFFFFF),
    edgeBottom: Color(0x66FFFFFF),
    shadow: Color(0x38000000),
  );

  static const GlassStyle dark = GlassStyle(
    tint: Color(0x6B46444E),
    gloss: Color(0x1AFFFFFF),
    edgeTop: Color(0x42FFFFFF),
    edgeBottom: Color(0x14FFFFFF),
    shadow: Color(0x80000000),
  );

  static GlassStyle forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Brightness of the closest macOS theme, falling back to the platform one.
Brightness glassBrightness(BuildContext context) {
  return MacosTheme.maybeOf(context)?.brightness ??
      MediaQuery.maybePlatformBrightnessOf(context) ??
      Brightness.light;
}

/// A frosted, glass-like surface in the spirit of macOS "liquid glass".
///
/// Blurs whatever is painted behind it, adds a translucent tint with a soft
/// specular gloss on the upper half, a thin gradient edge catching the light
/// and a drop shadow that is only painted outside of the shape, so that it
/// never dims the glass itself.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final GlassStyle? style;

  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = EdgeInsets.zero,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final GlassStyle glass =
        style ?? GlassStyle.forBrightness(glassBrightness(context));
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    return CustomPaint(
      painter: _GlassShadowPainter(radius: radius, color: glass.shadow),
      foregroundPainter: _GlassEdgePainter(
        radius: radius,
        top: glass.edgeTop,
        bottom: glass.edgeBottom,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: glass.blur,
            sigmaY: glass.blur,
            tileMode: TileMode.mirror,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: glass.tint,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [glass.gloss, glass.gloss.withValues(alpha: 0)],
                stops: const [0.0, 0.5],
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class _GlassShadowPainter extends CustomPainter {
  final double radius;
  final Color color;
  const _GlassShadowPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    // everything but the glass itself
    final Path outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(120))
      ..addRRect(shape);
    canvas.save();
    canvas.clipPath(outside);
    canvas.drawRRect(
      shape.shift(const Offset(0, 12)),
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawRRect(
      shape.shift(const Offset(0, 2)),
      Paint()
        ..color = color.withValues(alpha: color.a * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassShadowPainter old) =>
      old.radius != radius || old.color != color;
}

class _GlassEdgePainter extends CustomPainter {
  final double radius;
  final Color top;
  final Color bottom;
  const _GlassEdgePainter({
    required this.radius,
    required this.top,
    required this.bottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect shape = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius - 0.5),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassEdgePainter old) =>
      old.radius != radius || old.top != top || old.bottom != bottom;
}
