import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../model/library_health.dart';
import '../utils/events.dart';
import 'pill_button.dart';
import 'trax_colors.dart';

/// How tidy the library is, and where to go to improve it.
class TidyPanel extends StatelessWidget {
  final LibraryHealth health;
  const TidyPanel({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);

    final List<_Issue> issues = [
      if (health.mixedGenreAlbums > 0)
        _Issue(
          t.tidyMixedGenres(health.mixedGenreAlbums),
          ReviewKind.mixedGenres,
        ),
      if (health.noYearTracks > 0)
        _Issue(t.tidyNoYear(health.noYearTracks), ReviewKind.noYear),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.sidebar,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line, width: 0.5),
      ),
      child: Row(
        children: [
          _Ring(score: health.score, label: t.tidyLabel),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  health.isTidy
                      ? t.tidyAllGood
                      : t.tidyIssues(health.issueCount),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (issues.isNotEmpty) const SizedBox(height: 10),
                for (final _Issue issue in issues)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            issue.text,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.text,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PillButton(
                          label: t.tidyReview,
                          height: 24,
                          onPressed: () =>
                              eventBus.fire(ShowReviewEvent(issue.kind)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Issue {
  final String text;
  final ReviewKind kind;
  const _Issue(this.text, this.kind);
}

class _Ring extends StatelessWidget {
  static const double kSize = 112;
  final int score;
  final String label;
  const _Ring({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return SizedBox(
      width: kSize,
      height: kSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => CustomPaint(
          painter: _RingPainter(
            progress: value,
            track: colors.line,
            fill: colors.accent,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: colors.text,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.muted,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color fill;
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 9;
    final Rect rect = Offset.zero & size;
    final Rect arc = rect.deflate(stroke / 2);
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(arc, 0, 2 * pi, false, base);
    if (progress > 0) {
      canvas.drawArc(
        arc,
        -pi / 2,
        2 * pi * progress,
        false,
        base..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}
