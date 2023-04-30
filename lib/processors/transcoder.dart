import 'package:audiotranscode_ffi/audiotranscode_ffi.dart' as at_ffi;

class AudioTranscoder {
  Future<bool> transcodeMp3(String src, String dst, int bitrate) {
    return at_ffi.transcodeMp3(src, dst, bitrate);
  }

  Future<bool> transcodeFlac(
      String src, String dst, int samplerate, int bitspersample) {
    return at_ffi.transcodeFlac(src, dst, samplerate, bitspersample);
  }
}
