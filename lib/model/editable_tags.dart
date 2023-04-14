import 'package:taglib_ffi/taglib_ffi.dart';

class EditableTags extends Tags {
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
    editedCompilation = other.compilation;
  }

  factory EditableTags.safeFromTags(Tags? other) {
    return other == null ? EditableTags() : EditableTags.fromTags(other);
  }

  factory EditableTags.copy(EditableTags other) {
    EditableTags copy = EditableTags.fromTags(other);
    copy.editedCompilation = other.editedCompilation;
    return copy;
  }

  bool? editedCompilation;
}
