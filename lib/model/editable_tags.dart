import 'package:taglib_ffi/taglib_ffi.dart';

class EditableTags extends Tags {
  bool? _editedCompilation;

  EditableTags() : super();
  EditableTags.fromTags(Tags other)
      : super(
          valid: other.valid,
          title: other.title,
          album: other.album,
          artist: other.artist,
          performer: other.performer,
          composer: other.composer,
          genre: other.genre,
          copyright: other.copyright,
          comment: other.comment,
          year: other.year,
          compilation: other.compilation,
          volumeIndex: other.volumeIndex,
          volumeCount: other.volumeCount,
          trackIndex: other.trackIndex,
          trackCount: other.trackCount,
          duration: other.duration,
          numChannels: other.numChannels,
          sampleRate: other.sampleRate,
          bitsPerSample: other.bitsPerSample,
          bitrate: other.bitrate,
        ) {
    _editedCompilation = other.compilation;
  }

  factory EditableTags.safeFromTags(Tags? other) {
    return other == null ? EditableTags() : EditableTags.fromTags(other);
  }

  factory EditableTags.copy(EditableTags other) {
    return other.copyWith();
  }

  // ignore: unnecessary_getters_setters
  bool? get editedCompilation => _editedCompilation;
  set editedCompilation(bool? v) => _editedCompilation = v;

  EditableTags copyWith({
    String? title,
    String? album,
    String? artist,
    String? performer,
    String? composer,
    String? genre,
    int? year,
    int? volumeIndex,
    int? volumeCount,
    int? trackIndex,
    int? trackCount,
    bool? compilation,
    String? copyright,
    String? comment,
  }) {
    EditableTags copy = EditableTags.fromTags(
      Tags(
        title: title ?? this.title,
        album: album ?? this.album,
        artist: artist ?? this.artist,
        performer: performer ?? this.performer,
        composer: composer ?? this.composer,
        genre: genre ?? this.genre,
        year: year ?? this.year,
        volumeIndex: volumeIndex ?? this.volumeIndex,
        volumeCount: volumeCount ?? this.volumeCount,
        trackIndex: trackIndex ?? this.trackIndex,
        trackCount: trackCount ?? this.trackCount,
        compilation: compilation ?? this.compilation,
        copyright: copyright ?? this.copyright,
        comment: comment ?? this.comment,
      ),
    );
    copy._editedCompilation = _editedCompilation;
    return copy;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EditableTags &&
        other.title == title &&
        other.album == album &&
        other.artist == artist &&
        other.performer == performer &&
        other.composer == composer &&
        other.genre == genre &&
        other.year == year &&
        other.volumeIndex == volumeIndex &&
        other.volumeCount == volumeCount &&
        other.trackIndex == trackIndex &&
        other.trackCount == trackCount &&
        other.editedCompilation == editedCompilation &&
        other.copyright == copyright &&
        other.comment == comment;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        album.hashCode ^
        artist.hashCode ^
        performer.hashCode ^
        composer.hashCode ^
        genre.hashCode ^
        year.hashCode ^
        volumeIndex.hashCode ^
        volumeCount.hashCode ^
        trackIndex.hashCode ^
        trackCount.hashCode ^
        editedCompilation.hashCode ^
        copyright.hashCode ^
        comment.hashCode;
  }
}
