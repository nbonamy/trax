import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../model/track.dart';
import '../utils/artwork_provider.dart';
import '../utils/logger.dart';

class TraxServer {
  final Logger logger;
  final TraxDatabase database;
  final ArtworkProvider artworkProvider;

  late String _hostname;
  late HttpServer _httpServer;

  String get hostname => _hostname;
  int get port => _httpServer.port;

  static late TraxServer _instance;
  static TraxServer get instance {
    return _instance;
  }

  TraxServer(this.logger, this.database, this.artworkProvider) {
    _instance = this;
  }

  Future<void> start() async {
    // get hostname
    _hostname = await _getHostname();

    // now bind
    _httpServer = await HttpServer.bind(hostname, 0);
    _httpServer.listen(_processRequest);
    logger.i('[HTTP] Server started on $hostname:$port');
  }

  String getDownloadUrl(Track track) {
    return 'http://$hostname:$port/download/${track.id}';
  }

  String getArtworkUrl(Track track) {
    return 'http://$hostname:$port/artwork/${track.id}';
  }

  void _processRequest(HttpRequest request) async {
    logger.d('[HTTP] Request received: ${request.requestedUri}');
    String path = request.requestedUri.path;
    if (path.startsWith('/download')) {
      Track? track = await _getTrack(path, '/download');
      if (track == null) {
        _send404(request.response);
      } else {
        _processDownload(request.response, track);
      }
    } else if (path.startsWith('/artwork')) {
      Track? track = await _getTrack(path, '/artwork');
      if (track == null) {
        _send404(request.response);
      } else {
        _processArtwork(request.response, track);
      }
    } else {
      _send404(request.response);
    }
  }

  void _processDownload(HttpResponse response, Track track) {
    File f = File(track.filename);
    f.exists().then((found) {
      if (found) {
        response.headers.contentType = ContentType(
          'audio',
          '*',
        );
        response.headers.add('content-disposition',
            'attachment; filename="${Uri.encodeFull(p.basename(track.filename))}";');
        f.openRead().pipe(response);
      } else {
        _send404(response);
      }
    });
  }

  void _processArtwork(HttpResponse response, Track track) async {
    Uint8List? bytes = await artworkProvider.getArwork(track);
    if (bytes == null) {
      _send404(response);
    } else {
      response.headers.contentType = ContentType('image', '*');
      response.add(bytes.toList());
      response.close();
    }
  }

  void _send404(HttpResponse response) {
    response.statusCode = HttpStatus.notFound;
    response.close();
  }

  Future<Track?> _getTrack(String path, String prefix) async {
    String id = path.substring(prefix.length + 1);
    Track? track = await database.getTrackById(id);
    return track;
  }

  Future<String> _getHostname() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.isLoopback == false && addr.type.name == 'IPv4') {
          return addr.address;
        }
      }
    }
    return 'localhost';
  }
}
