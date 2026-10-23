import 'package:flutter/material.dart';

import '../utils/track_utils.dart';
import 'artist_profile_pic.dart';
import 'trax_colors.dart';

/// One row of the source list.
class ArtistWidget extends StatefulWidget {
  static const double kHeight = 34;

  final String name;
  final bool selected;
  final Function onSelectArtist;
  const ArtistWidget({
    super.key,
    required this.name,
    required this.selected,
    required this.onSelectArtist,
  });

  @override
  State<ArtistWidget> createState() => _ArtistWidgetState();
}

class _ArtistWidgetState extends State<ArtistWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final TraxColors colors = TraxColors.of(context);
    final Color background = widget.selected
        ? colors.accent
        : (_hovered ? colors.hover : Colors.transparent);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelectArtist(widget.name),
        child: Container(
          height: ArtistWidget.kHeight,
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              ArtistProfilePic(name: widget.name, selected: widget.selected),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  TrackUtils.getDisplayArtist(widget.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: widget.selected ? colors.accentInk : colors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small gray caption introducing a group of rows.
class SidebarSectionHeader extends StatelessWidget {
  final String label;
  const SidebarSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ArtistWidget.kHeight + 2,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: TraxColors.of(context).faint,
        ),
      ),
    );
  }
}
