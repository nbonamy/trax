import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../components/context_menu.dart' as ctxm;
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../model/track.dart';
import '../utils/consts.dart';
import '../utils/events.dart';
import '../utils/num_utils.dart';
import '../utils/track_utils.dart';

class TrackWidget extends StatelessWidget {
  final Track track;
  final Function onTap;
  final Function onDoubleTap;
  const TrackWidget({
    super.key,
    required this.track,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(
      builder: (context, selectionModel, child) {
        AppLocalizations t = AppLocalizations.of(context)!;
        bool selected = selectionModel.contains(track);
        Color bgColor = selected ? Colors.blue : Colors.transparent;
        Color fgColor = selected ? Colors.white : Colors.black;
        Color fgColor2 =
            selected ? fgColor : fgColor.withOpacity(Consts.fadedOpacity);
        return GestureDetector(
          onTapDown: (_) => onTap(track),
          onDoubleTap: () => onDoubleTap(track),
          child: _getContextMenu(
            t,
            selectionModel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: bgColor,
              child: Row(
                children: [
                  Text(
                    track.displayTrackIndex,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: fgColor2,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      track.displayTitle,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: fgColor,
                      ),
                    ),
                  ),
                  Text(
                    track.tags?.duration.formatDuration(skipHours: true) ?? '',
                    style: TextStyle(
                      color: fgColor2,
                      fontSize: 13,
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
            label: t.menuEditDelete,
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
