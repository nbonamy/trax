import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../model/preferences.dart';
import '../utils/events.dart';
import 'trax_colors.dart';

/// Drop files or folders here to add them to the library.
class DropZone extends StatefulWidget {
  const DropZone({super.key});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _dragging = false;
  ImportFileOp? _op;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    final Preferences preferences = Preferences.of(context);
    final ImportFileOp op = _op ?? preferences.importFileOp;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (detail) {
        setState(() => _dragging = false);
        eventBus.fire(ImportFilesEvent(
          detail.files.map((f) => f.path).toList(),
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _dragging ? colors.accentFill : const Color(0x00000000),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _dragging ? colors.accent : colors.line,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  transform:
                      Matrix4.translationValues(0, _dragging ? -4 : 0, 0),
                  decoration: BoxDecoration(
                    color: colors.accentFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_up_doc,
                    size: 24,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.dropTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t.dropDescription,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          color: colors.muted,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  t.dropOnImport,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.muted,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 10),
                _Segmented(
                  labels: [t.importFileOpCopy, t.importFileOpMove],
                  selected: op.index,
                  onSelected: (i) {
                    final ImportFileOp value = ImportFileOp.values[i];
                    preferences.importFileOp = value;
                    setState(() => _op = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  const _Segmented({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.well,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? colors.field : null,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: i == selected
                        ? [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.18),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == selected ? colors.text : colors.muted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
