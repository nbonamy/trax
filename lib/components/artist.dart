import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArtistWidget extends StatefulWidget {
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
          color: widget.selected
              ? const Color.fromRGBO(213, 208, 206, 1.0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.onSelectArtist(widget.name),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.person_alt_circle,
                size: 32,
                color: Colors.black.withOpacity(
                  0.7,
                ),
              ),
              const SizedBox(width: 16),
              Text(widget.name),
            ],
          ),
        ),
      ),
    );
  }
}
