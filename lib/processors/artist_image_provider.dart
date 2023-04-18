import 'dart:convert';
import 'dart:io';

import 'package:mutex/mutex.dart';

import '../utils/path_utils.dart';

class ArtistImageProvider {
  static final Map<String, String?> _cache = {};
  late String _cacheFilename;
  final HttpClient _httpClient = HttpClient();
  final Mutex _cacheMutex = Mutex();

  ArtistImageProvider() {
    _load();
  }

  Future<String?> getProfilePicUrl(String artist) async {
    String? profilePicUrl;

    // check cache
    if (_cache.containsKey(artist) == false) {
      // get it
      try {
        HttpClientRequest request = await _httpClient.getUrl(Uri.parse(
            'https://scrapper.bonamy.fr/lastfm.php?artist=${Uri.encodeComponent(artist.toLowerCase())}&exact=true'));
        HttpClientResponse response = await request.close();

        // decode
        final respBody = await response.transform(utf8.decoder).join();
        Map respJson = jsonDecode(respBody);
        profilePicUrl = respJson['results'][0];
      } catch (_) {}

      // store in cache
      _cache[artist] = profilePicUrl;
      _save();
    }

    // done
    return _cache[artist];
  }

  void _load() {
    _cacheMutex.protect(() async {
      _cacheFilename = await SystemPath.artistCacheFile();
      final File cacheFile = File(_cacheFilename);
      if (await cacheFile.exists()) {
        try {
          final jsonStr = await cacheFile.readAsString();
          _cache.addAll(jsonDecode(jsonStr) as Map<String, String?>);
        } catch (_) {}
      }
    });
  }

  void _save() {
    _cacheMutex.protect(() async {
      try {
        final jsonStr =
            jsonEncode(Map.from(_cache)..removeWhere((k, v) => v == null));
        final File cacheFile = File(_cacheFilename);
        await cacheFile.writeAsString(jsonStr);
      } catch (_) {}
    });
  }
}
