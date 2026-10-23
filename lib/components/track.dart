import 'package:flutter/material.dart';
import 'package:trax/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../components/context_menu.dart' as ctxm;
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../model/track.dart';
import 'trax_colors.dart';
import '../utils/events.dart';
import '../utils/num_utils.dart';
import '../utils/track_utils.dart';

/// Optional columns, for screens where the point is a tag's value.
class TrackColumns {
  final bool genre;
  final bool year;
  const TrackColumns({this.genre = false, this.year = false});
}

class TrackWidget extends StatelessWidget {
  static const double kHeight = 34;

  final Track track;
  final int index;
  final TrackColumns columns;
  final Function onTap;
  final Function onDoubleTap;
  const TrackWidget({
    super.key,
    required this.track,
    this.index = 0,
    this.columns = const TrackColumns(),
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(
      builder: (context, selectionModel, child) {
        AppLocalizations t = AppLocalizations.of(context)!;
        final TraxColors colors = TraxColors.of(context);
        bool selected = selectionModel.contains(track);
        Color bgColor = selected
            ? colors.accentFill
            : (index.isOdd ? colors.stripe : Colors.transparent);
        TextStyle style = TextStyle(fontSize: 13, color: colors.text);
        TextStyle muted = TextStyle(fontSize: 13, color: colors.muted);
        return GestureDetector(
          onTapDown: (_) => onTap(track),
          onDoubleTap: () => onDoubleTap(track),
          child: _getContextMenu(
            t,
            selectionModel,
            child: Container(
              height: kHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      track.displayTrackIndex,
                      style: muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      track.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    ),
                  ),
                  if (columns.genre)
                    SizedBox(
                      width: 110,
                      child: Text(
                        TrackUtils.getDisplayGenre(track.safeTags.genre),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                    ),
                  if (columns.year)
                    SizedBox(
                      width: 56,
                      child: Text(
                        track.safeTags.year == 0
                            ? '\u2014'
                            : '${track.safeTags.year}',
                        style: style,
                      ),
                    ),
                  SizedBox(
                    width: 112,
                    child: Text(
                      track.formatSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      track.tags?.duration.formatDuration(skipHours: true) ??
                          '',
                      textAlign: TextAlign.right,
                      style: muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getContextMenu(
    AppLocalizations t,
    SelectionModel selectionModel, {
    required Widget child,
  }) {
    return ctxm.ContextMenu(
      menu: ctxm.Menu(
        items: [
          ctxm.MenuItem(
            label: t.menuTrackInfo,
            onClick: (_) => eventBus.fire(
              MenuActionEvent(MenuAction.trackInfo),
            ),
          ),
          if (selectionModel.get.length == 1) ...[
            ctxm.MenuItem(
              label: t.menuTrackPlay,
              onClick: (_) => onDoubleTap(track),
            ),
            ctxm.MenuItem.separator(),
            ctxm.MenuItem(
              label: t.menuFileReveal,
              onClick: (_) => eventBus.fire(
                MenuActionEvent(MenuAction.fileReveal),
              ),
            ),
          ],
          ctxm.MenuItem.separator(),
          ctxm.MenuItem(
            label: t.menuEditDeleteSoft,
            onClick: (_) => eventBus.fire(
              MenuActionEvent(MenuAction.editDelete),
            ),
          ),
        ],
      ),
      onBeforeShowMenu: () {
        if (selectionModel.get.contains(track) == false) {
          selectionModel.set([track]);
          return true;
        }
        return false;
      },
      child: child,
    );
  }
}
