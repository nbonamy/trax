import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../model/track.dart';

class _CacheKey {
  final String artist;
  final String album;

  _CacheKey(this.artist, this.album);
  factory _CacheKey.fromTrack(Track track) {
    if (track.safeTags.compilation) {
      return _CacheKey(Track.kArtistCompilations, track.safeTags.album);
    } else {
      return _CacheKey(track.safeTags.artist, track.safeTags.album);
    }
  }

  @override
  String toString() {
    return '$artist@@@$album';
  }
}

class _CacheEntry {
  final _CacheKey key;
  final Uint8List? bytes;
  late DateTime lastAccess;

  _CacheEntry(this.key, this.bytes) {
    lastAccess = DateTime.now();
  }
}

class ArtworkProvider extends ChangeNotifier {
  final int maxSize;
  final TagLib _tagLib = TagLib();
  final Map<String, _CacheEntry> _cache = {};

  static ArtworkProvider of(BuildContext context) {
    return Provider.of<ArtworkProvider>(context, listen: false);
  }

  ArtworkProvider({
    this.maxSize = 1024 * 1024 * 1024 * 16,
  });

  int get size =>
      _cache.values.fold(0, (size, entry) => size + (entry.bytes?.length ?? 0));

  Future<Uint8List?> getArwork(Track? track, {bool useCache = false}) async {
    // check
    if (track == null) {
      return null;
    }

    // check cache
    _CacheKey cacheKey = _CacheKey.fromTrack(track);
    if (useCache) {
      if (_cache.containsKey(cacheKey.toString())) {
        _CacheEntry entry = _cache[cacheKey.toString()]!;
        entry.lastAccess = DateTime.now();
        return entry.bytes;
      }
    }

    // we need to grab it
    String filename = track.filename;
    Uint8List? artworkBytes = await _tagLib.getArtworkBytes(filename);
    if (artworkBytes != null && useCache) {
      _cache[cacheKey.toString()] = _CacheEntry(cacheKey, artworkBytes);
      _purge();
    }
    return artworkBytes;
  }

  void evict(Track track) {
    _CacheKey cacheKey = _CacheKey.fromTrack(track);
    _evict(cacheKey);
  }

  void _evict(_CacheKey key) {
    _cache.remove(key.toString());
  }

  void _purge() {
    while (size > maxSize) {
      _CacheEntry oldest = _cache.values
          .reduce((a, b) => a.lastAccess.compareTo(b.lastAccess) < 0 ? a : b);
      _evict(oldest.key);
    }
  }
}
