import 'package:flutter/cupertino.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../audioplayer/glass_player.dart';
import '../components/database_builder.dart';
import '../components/drop_zone.dart';
import '../components/pill_button.dart';
import '../components/recents.dart';
import '../components/tidy_panel.dart';
import '../components/trax_colors.dart';
import '../model/menu_actions.dart';
import '../utils/events.dart';
import '../utils/num_utils.dart';

class StartWidget extends StatelessWidget {
  static const double kWideLayout = 860;

  /// Past this the page stops growing: very wide windows keep a readable
  /// column instead of stretching panels and pushing buttons far from titles.
  static const double kMaxContentWidth = 1120;

  const StartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    TraxColors colors = TraxColors.of(context);
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                48,
                12,
                48,
                48 + GlassPlayerBar.kContentInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, t, colors),
                  const SizedBox(height: 28),
                  _overview(),
                  const SizedBox(height: 36),
                  Text(
                    t.addedRecently,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const RecentlyAddedWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations t, TraxColors colors) {
    // full width, or spaceBetween has nothing to spread over
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        runSpacing: 16,
        spacing: 24,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.startLibrary,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.text,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              DatabaseBuilder(
                future: (database) => database.info(),
                placeholder: const SizedBox(height: 18),
                builder: (context, database, info) => Text(
                  t.startSubtitle(
                    t.statsTracks(info.tracks),
                    info.duration
                        .formatDuration(
                          skipSeconds: true,
                          suffixHours: t.statsDurationHours,
                          suffixMinutes: t.statsDurationMinutes,
                        )
                        .trim(),
                    t.statsArtists(info.artists),
                    t.statsAlbums(info.albums),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.muted,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PillButton(
                label: t.menuFileImport,
                icon: CupertinoIcons.add,
                style: PillStyle.filled,
                onPressed: () =>
                    eventBus.fire(MenuActionEvent(MenuAction.fileImport)),
              ),
              const SizedBox(width: 8),
              PillButton(
                label: t.menuToolsTranscode,
                icon: CupertinoIcons.arrow_right_arrow_left,
                onPressed: () =>
                    eventBus.fire(MenuActionEvent(MenuAction.toolsTranscode)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overview() {
    return DatabaseBuilder(
      future: (database) => database.health(),
      placeholder: const SizedBox(height: 120),
      builder: (context, database, health) => LayoutBuilder(
        builder: (context, constraints) {
          final Widget tidy = TidyPanel(health: health);
          const Widget drop = DropZone();
          if (constraints.maxWidth < kWideLayout) {
            return Column(
              children: [tidy, const SizedBox(height: 16), drop],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: tidy),
                const SizedBox(width: 16),
                const Expanded(flex: 1, child: drop),
              ],
            ),
          );
        },
      ),
    );
  }
}
