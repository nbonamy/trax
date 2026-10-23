import 'package:flutter/material.dart';

import 'trax_colors.dart';

enum PillStyle { filled, tinted }

/// Compact rounded button used across the redesigned screens.
class PillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PillStyle style;
  final double height;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = PillStyle.tinted,
    this.height = 30,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    final bool enabled = widget.onPressed != null;
    final bool filled = widget.style == PillStyle.filled;
    Color background = filled ? colors.accent : colors.hover;
    if (_hovered && enabled) {
      background = filled
          ? Color.lerp(colors.accent, colors.text, 0.08)!
          : Color.lerp(colors.hover, colors.text, 0.06)!;
    }
    final Color foreground = filled ? colors.accentInk : colors.text;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _pressed ? 0.97 : 1,
            child: Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Container(
                height: widget.height,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  border: filled
                      ? null
                      : Border.all(color: colors.line, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 14, color: foreground),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
