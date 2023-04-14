import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/database_builder.dart';
import '../components/recents.dart';
import '../components/title.dart';
import '../utils/time_utils.dart';

class StartWidget extends StatelessWidget {
  const StartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 128),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleWidget(title: t.startLibrary),
            DatabaseBuilder(
              future: (database) => database.info(),
              builder: (context, database, info) {
                TextStyle infoStyle = const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.inactiveGray,
                );
                String durationStr = info.duration.formatDuration(
                  suffixHours: t.statsDurationHours,
                  suffixMinutes: t.statsDurationMinutes,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.statsTracks(info.tracks).toUpperCase()} / ${durationStr.toUpperCase()}',
                      style: infoStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${t.statsArtists(info.artists).toUpperCase()} / ${t.statsAlbums(info.albums).toUpperCase()}',
                      style: infoStyle,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            TitleWidget(title: t.addedRecently),
            const RecentlyAddedWidget(),
          ],
        ),
      ),
    );
  }
}
