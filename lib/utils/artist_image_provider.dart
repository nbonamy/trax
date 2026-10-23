import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

/// Looks up artist photos directly from Last.fm.
class ArtistImageProvider {
  final http.Client _client;
  final Map<String, _ImageLookup> _cache = {};

  ArtistImageProvider({http.Client? client})
      : _client = client ?? http.Client();

  /// Keep pending lookups and their results for ten minutes, including misses,
  /// so rebuilding or scrolling the sidebar never repeatedly hits Last.fm.
  Future<String?> imageUrl(String artist) {
    final name = artist.trim();
    if (name.isEmpty) return Future.value(null);
    final key = name.toLowerCase();
    final now = DateTime.now();
    final cached = _cache[key];
    if (cached != null && now.isBefore(cached.expires)) return cached.result;
    final result = _lookup(name);
    _cache[key] = _ImageLookup(result, now.add(const Duration(minutes: 10)));
    return result;
  }

  Future<String?> _lookup(String artist) async {
    try {
      final response = await _client
          .get(Uri(
            scheme: 'https',
            host: 'www.last.fm',
            pathSegments: ['music', artist, '+images'],
          ))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      for (final image in parse(response.body).querySelectorAll('li a img')) {
        final url = Uri.tryParse(image.attributes['src'] ?? '');
        if (url == null || url.scheme != 'https') continue;
        if (url.host != 'lastfm.freetls.fastly.net' &&
            url.host != 'lastfm-img.freetls.fastly.net') {
          continue;
        }
        return url.toString().replaceFirst(
              RegExp(r'/i/u/(?:64s|avatar70s|174s|300x300|770x0)/'),
              '/i/u/avatar170s/',
            );
      }
      return null;
    } on Exception {
      // Offline, timed out, or rejected by Last.fm: keep the monogram.
      return null;
    }
  }

  void dispose() => _client.close();
}

class _ImageLookup {
  final Future<String?> result;
  final DateTime expires;

  _ImageLookup(this.result, this.expires);
}
