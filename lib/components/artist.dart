import 'package:flutter/material.dart';
import '../utils/consts.dart';
import '../utils/track_utils.dart';
import 'artist_profile_pic.dart';

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
          color: selected ? Consts.sideBarSelectColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onSelectArtist(name),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const ArtistProfilePic(),
              /*FutureBuilder<String?>(
                future: _artistProfilePic(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false || snapshot.data == null) {
                    return const ArtistProfilePic();
                  }
                  return CachedNetworkImage(
                    imageUrl: snapshot.data!,
                    imageBuilder: (context, provider) {},
                    placeholder: (_, __) => const ArtistProfilePic(),
                    errorWidget: (_, __, ___) => const ArtistProfilePic(),
                  );
                },
              ),*/
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  TrackUtils.getDisplayArtist(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<String?> _artistProfilePic() async {
  //   try {
  //     String url =
  //         'https://scrapper.bonamy.fr/lastfm.php?artist=${Uri.encodeComponent(name)}&exact=true';
  //     Response response = await get(Uri.parse(url));
  //     Map json = jsonDecode(response.body);
  //     if (json.containsKey('results')) {
  //       return json['results'][0];
  //     }
  //   } catch (e) {
  //     //print(e);
  //   }
  //   return null;
  // }
}
