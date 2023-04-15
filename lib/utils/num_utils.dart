import 'dart:math';

extension NumFormatting on int {
  String formatDuration({
    bool skipHours = false,
    bool skipSeconds = false,
    String suffixHours = ':',
    String suffixMinutes = ':',
    String suffixSeconds = '',
  }) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    Duration duration = Duration(seconds: this);
    String twoDigitMinutes = twoDigits((skipHours ? duration.inHours * 60 : 0) +
        duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String durationStr = skipHours ? '' : '${duration.inHours}$suffixHours';
    durationStr = '$durationStr$twoDigitMinutes$suffixMinutes';
    if (!skipSeconds) {
      durationStr = '$durationStr$twoDigitSeconds$suffixSeconds';
    }
    return durationStr;
  }

  String formatFilesize({
    int decimals = 0,
  }) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    if (this == 0) return '0${suffixes[0]}';
    var i = (log(this) / log(1024)).floor();
    return '${(this / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
