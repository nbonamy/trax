import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class ArtistProfilePic extends StatelessWidget {
  const ArtistProfilePic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: MacosIcon(
        CupertinoIcons.music_mic,
        size: 24,
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }
}
