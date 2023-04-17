import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import '../model/track.dart';
import '../utils/track_utils.dart';

class AudioPlayer extends ChangeNotifier {
  static AudioPlayer of(BuildContext context) {
    return Provider.of<AudioPlayer>(context, listen: false);
  }

  final ja.AudioPlayer _player = ja.AudioPlayer();
  TrackList _playlist = [];

  AudioPlayer() {
    _player.playerStateStream.listen(_notify);
    //_player.positionStream.listen(_notify);
    _player.currentIndexStream.listen(_notify);
    _player.playingStream.listen(_notify);
    _player.playbackEventStream.listen(_notify);
  }

  bool get isStopped {
    return _playlist.isEmpty;
  }

  bool get isPlaying {
    return _player.playing;
  }

  bool get canNext {
    return _player.hasNext;
  }

  bool get canPrevious {
    return _player.hasPrevious;
  }

  Track? get current {
    if (_player.currentIndex == null ||
        _player.currentIndex! > _playlist.length - 1) {
      return null;
    } else {
      return _playlist[_player.currentIndex!];
    }
  }

  Stream<double?> get progressStream {
    return _player.positionStream.map((position) => _player.duration == null
        ? null
        : (position.inSeconds.toDouble() /
            _player.duration!.inSeconds.toDouble()));
  }

  double get volume {
    return _player.volume;
  }

  void play(
    TrackList playlist, {
    int initialIndex = 0,
  }) async {
    _playlist = playlist;
    final audioSource = ja.ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: playlist
          .map(
            (t) => ja.AudioSource.file(
              t.filename,
              tag: MediaItem(
                id: t.filename,
                title: t.displayTitle,
                displayTitle: t.displayTitle,
                album: t.displayAlbum,
                artist: t.displayArtist,
                genre: t.displayGenre,
                duration: Duration(seconds: t.safeTags.duration),
              ),
            ),
          )
          .toList(),
    );
    await _player.setAudioSource(
      audioSource,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
    await _player.play();
  }

  void pause() {
    if (isPlaying) {
      _player.pause();
    }
  }

  void resume() {
    if (!isStopped) {
      _player.play();
    }
  }

  void playpause() {
    isPlaying ? pause() : resume();
  }

  void seekTo(double progress) {
    if (_player.duration != null) {
      _player.seek(
          Duration(seconds: (_player.duration!.inSeconds * progress).toInt()));
    }
  }

  void previous() {
    if (canPrevious) {
      _player.seekToPrevious();
    }
  }

  void next() {
    if (canNext) {
      _player.seekToNext();
    }
  }

  void _notify(dynamic event) {
    notifyListeners();
  }
}
