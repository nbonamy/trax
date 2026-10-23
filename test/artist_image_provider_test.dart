import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trax/utils/artist_image_provider.dart';

void main() {
  test('looks up the artist gallery and accepts both Last.fm image hosts',
      () async {
    for (final host in [
      'lastfm.freetls.fastly.net',
      'lastfm-img.freetls.fastly.net',
    ]) {
      final images = ArtistImageProvider(client: MockClient((request) async {
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'www.last.fm');
        expect(request.url.pathSegments, ['music', 'AC/DC', '+images']);
        return http.Response('''
          <img src="https://$host/i/u/avatar170s/not-in-gallery.jpg">
          <li><a><img src="https://elsewhere.example/photo.jpg"></a></li>
          <li><a><img src="https://$host.evil.example/photo.jpg"></a></li>
          <li><a><img src="http://$host/i/u/avatar170s/insecure.jpg"></a></li>
          <li><a><img src="https://$host/i/u/avatar170s/artist.jpg"></a></li>
        ''', 200);
      }));
      addTearDown(images.dispose);

      expect(await images.imageUrl('AC/DC'),
          'https://$host/i/u/avatar170s/artist.jpg');
    }
  });

  test('coalesces and caches lookups regardless of case or surrounding spaces',
      () async {
    var requests = 0;
    final response = Completer<http.Response>();
    final images = ArtistImageProvider(client: MockClient((request) {
      requests++;
      return response.future;
    }));
    addTearDown(images.dispose);

    final first = images.imageUrl('The Beatles');
    final second = images.imageUrl('  the BEATLES  ');
    response.complete(http.Response('''
      <li><a><img src="https://lastfm-img.freetls.fastly.net/i/u/300x300/beatles.jpg"></a></li>
    ''', 200));
    const expected =
        'https://lastfm-img.freetls.fastly.net/i/u/avatar170s/beatles.jpg';
    expect(await first, expected);
    expect(await second, expected);
    expect(await images.imageUrl('THE BEATLES'), expected);
    expect(requests, 1);
  });

  test('unavailable photos return no image and are not retried on rebuild',
      () async {
    final responses = <Future<http.Response> Function()>[
      () async => http.Response('<title>Client Challenge</title>', 200),
      () async => http.Response('<html>No photos</html>', 200),
      () async => http.Response('''
        <li><a><img src="https://lastfm-img.freetls.fastly.net/i/u/avatar170s/error.jpg"></a></li>
      ''', 503),
      () async => throw http.ClientException('offline'),
      () async => throw TimeoutException('timed out'),
    ];
    for (final respond in responses) {
      var requests = 0;
      final images = ArtistImageProvider(client: MockClient((request) {
        requests++;
        return respond();
      }));
      addTearDown(images.dispose);
      expect(await images.imageUrl('Artist'), isNull);
      expect(await images.imageUrl('artist'), isNull);
      expect(requests, 1);
    }
  });

  test('blank artist names never make a request', () async {
    var requests = 0;
    final images = ArtistImageProvider(client: MockClient((request) async {
      requests++;
      return http.Response('', 200);
    }));
    addTearDown(images.dispose);
    expect(await images.imageUrl('  '), isNull);
    expect(requests, 0);
  });
}
