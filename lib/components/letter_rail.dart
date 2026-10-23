import 'package:flutter/material.dart';

import 'trax_colors.dart';

/// Thin A-Z strip along the source list: tap a letter to jump to it.
class LetterRail extends StatelessWidget {
  static const double kMaxLetterHeight = 14;

  final List<String> letters;
  final ValueChanged<String> onSelected;
  const LetterRail({
    super.key,
    required this.letters,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double each = letters.isEmpty
            ? kMaxLetterHeight
            : (constraints.maxHeight / letters.length)
                .clamp(0.0, kMaxLetterHeight);
        // not even 8px per letter: better to show nothing than a smear
        if (each < 8) return const SizedBox.shrink();
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final String letter in letters)
              _RailLetter(
                letter: letter,
                height: each,
                color: colors.faint,
                hoverColor: colors.accent,
                onTap: () => onSelected(letter),
              ),
          ],
        );
      },
    );
  }
}

class _RailLetter extends StatefulWidget {
  final String letter;
  final double height;
  final Color color;
  final Color hoverColor;
  final VoidCallback onTap;
  const _RailLetter({
    required this.letter,
    required this.height,
    required this.color,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_RailLetter> createState() => _RailLetterState();
}

class _RailLetterState extends State<_RailLetter> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: 14,
          height: widget.height,
          child: Center(
            child: Text(
              widget.letter,
              style: TextStyle(
                fontSize: 9,
                height: 1,
                fontWeight: FontWeight.w600,
                color: _hovered ? widget.hoverColor : widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
