import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class ArtistProfilePic extends StatelessWidget {
  final Widget? profilePic;
  final IconData? iconData;
  const ArtistProfilePic({
    Key? key,
    this.profilePic,
    this.iconData,
  }) : super(key: key);

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
        // gradient: const LinearGradient(
        //   begin: Alignment.bottomCenter,
        //   end: Alignment.topCenter,
        //   colors: [
        //     Color.fromRGBO(135, 140, 150, 1.0),
        //     Color.fromRGBO(164, 170, 182, 1.0),
        //   ],
        // ),
      ),
      child: profilePic ??
          MacosIcon(
            iconData ?? CupertinoIcons.music_mic,
            size: 24,
            color: Colors.black.withOpacity(0.7),
          ),
    );
  }
}
