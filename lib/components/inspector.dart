import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trax/l10n/app_localizations.dart';

import '../model/inspector_fields.dart';
import '../model/menu_actions.dart';
import '../model/selection.dart';
import '../utils/events.dart';
import 'artwork_async.dart';
import 'pill_button.dart';
import 'trax_colors.dart';

/// Right-hand panel: the tags of the selected tracks, with the usual actions.
/// Slides open as soon as something is selected.
class InspectorPanel extends StatelessWidget {
  static const double kWidth = 300;

  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    return Consumer<SelectionModel>(
      builder: (context, selection, child) {
        final InspectorFields fields = InspectorFields.from(selection.get);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: fields.isEmpty ? 0 : kWidth,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: colors.sidebar,
            border: fields.isEmpty
                ? null
                : Border(left: BorderSide(color: colors.line, width: 0.5)),
          ),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: kWidth,
            maxWidth: kWidth,
            child: fields.isEmpty
                ? const SizedBox.shrink()
                : _Content(fields: fields, selection: selection),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final InspectorFields fields;
  final SelectionModel selection;
  const _Content({required this.fields, required this.selection});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.inspectorSelected(fields.count),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 16),
          Center(child: _artwork(t, colors)),
          const SizedBox(height: 18),
          _field(context, t.tagTitle, fields.title),
          _field(context, t.tagAlbum, fields.album),
          _field(context, t.tagArtist, fields.albumArtist),
          _field(context, t.tagGenre, fields.genre),
          _field(context, t.tagYear, fields.year),
          _field(context, t.tagTrackIndex, fields.trackNumber),
          const SizedBox(height: 8),
          PillButton(
            label: t.inspectorEditTags,
            style: PillStyle.filled,
            height: 32,
            onPressed: () => _fire(MenuAction.trackInfo),
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: colors.line),
          const SizedBox(height: 6),
          _Action(
            icon: Icons.auto_fix_high,
            label: t.menuTrackCleanupTitles,
            enabled: fields.canCleanupTitles,
            onPressed: () => _fire(MenuAction.trackCleanupTitles),
          ),
          _Action(
            icon: Icons.swap_horiz,
            label: t.menuTrackTranscode,
            enabled: true,
            onPressed: () => _fire(MenuAction.trackTranscode),
          ),
          _Action(
            icon: Icons.folder_open,
            label: t.menuFileReveal,
            enabled: fields.canReveal,
            onPressed: () => _fire(MenuAction.fileReveal),
          ),
        ],
      ),
    );
  }

  Widget _artwork(AppLocalizations t, TraxColors colors) {
    const double size = 148;
    if (!fields.sameAlbum) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.well,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          t.inspectorMixedArtwork,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: colors.muted,
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AsyncArtwork(
        track: selection.get.first,
        size: size,
        useCache: false,
        defaultPlaceholderBorderColor: colors.line,
      ),
    );
  }

  Widget _field(BuildContext context, String label, InspectorField field) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final TraxColors colors = TraxColors.of(context);
    final bool placeholder = field.isMixed || field.isEmpty;
    final String text =
        field.isMixed ? t.tagsMixed : (field.isEmpty ? '—' : field.value!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.faint,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: colors.field,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.line, width: 0.5),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontStyle: field.isMixed ? FontStyle.italic : FontStyle.normal,
                color: placeholder ? colors.muted : colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fire(MenuAction action) => eventBus.fire(MenuActionEvent(action));
}

class _Action extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  const _Action({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  State<_Action> createState() => _ActionState();
}

class _ActionState extends State<_Action> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    final Color color = widget.enabled ? colors.text : colors.faint;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onPressed : null,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _hovered && widget.enabled ? colors.hover : null,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.enabled ? colors.accent : colors.faint,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(fontSize: 13, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
