import 'package:audiotranscode_ffi/audiotranscode_ffi.dart' as at_ffi;

class AudioSettingBitrate {
  final String name;
  final int bitrate;
  AudioSettingBitrate(this.name, this.bitrate);
}

class AudioSettingBitsPerSample {
  final String name;
  final int bitsPerSample;
  AudioSettingBitsPerSample(this.name, this.bitsPerSample);
}

class AudioSettingSampleRate {
  final String name;
  final int sampleRate;
  AudioSettingSampleRate(this.name, this.sampleRate);
}

class AudioTranscoder {
  static final List<AudioSettingBitrate> kSettingsBitrate = [
    AudioSettingBitrate('128 kbps', 128000),
    AudioSettingBitrate('160 kbps', 160000),
    AudioSettingBitrate('192 kbps', 192000),
    AudioSettingBitrate('320 kbps', 320000),
  ];

  static final List<AudioSettingBitsPerSample> kSettingsBitsPerSample = [
    AudioSettingBitsPerSample('16 bits', 16),
    AudioSettingBitsPerSample('24 bits', 24),
    AudioSettingBitsPerSample('32 bits', 32),
  ];

  static final List<AudioSettingSampleRate> kSettingsSampleRate = [
    AudioSettingSampleRate('44.1 kHz', 44100),
    AudioSettingSampleRate('48 kHz', 48000),
    AudioSettingSampleRate('88.2 kHz', 88200),
    AudioSettingSampleRate('96 kHz', 96000),
  ];

  Future<bool> transcodeMp3(String src, String dst, int bitrate) {
    return at_ffi.transcodeMp3(src, dst, bitrate);
  }

  Future<bool> transcodeFlac(
      String src, String dst, int sampleRate, int bitsPerSample) {
    return at_ffi.transcodeFlac(src, dst, sampleRate, bitsPerSample);
  }
}
