extension TimeFormatting on int {
  String formatDuration({
    bool skipHours = false,
    String suffixHours = ':',
    String suffixMinutes = ':',
    String suffixSeconds = '',
  }) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    Duration duration = Duration(seconds: this);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (skipHours) {
      return '$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '${duration.inHours}$suffixHours$twoDigitMinutes$suffixMinutes$twoDigitSeconds$suffixSeconds';
    }
  }
}
