import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArtistWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(213, 208, 206, 1.0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onSelectArtist(name),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.black.withOpacity(
                    0.25,
                  )),
                  color: Colors.black.withOpacity(
                    0.2,
                  ),
                ),
                child: Icon(
                  CupertinoIcons.music_mic,
                  size: 24,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Text(name),
            ],
          ),
        ),
      ),
    );
  }
}
