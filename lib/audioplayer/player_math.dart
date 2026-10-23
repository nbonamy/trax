import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/cupertino.dart';

enum PlayerRepeat { off, all, one }

extension PlayerRepeatCycle on PlayerRepeat {
  PlayerRepeat get next =>
      PlayerRepeat.values[(index + 1) % PlayerRepeat.values.length];
}

/// 3 -> "0:03", 227 -> "3:47", 3725 -> "1:02:05".
String formatClock(int seconds) {
  final int s = seconds < 0 ? 0 : seconds;
  final int h = s ~/ 3600;
  final int m = (s % 3600) ~/ 60;
  final String ss = (s % 60).toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
  return '$m:$ss';
}

/// Position of a pointer along a horizontal bar, as a 0..1 fraction.
double fractionForDx(double dx, double width) {
  if (width <= 0) return 0;
  return clampDouble(dx / width, 0.0, 1.0);
}

IconData volumeIcon(double volume) {
  if (volume <= 0) return CupertinoIcons.speaker_slash_fill;
  if (volume < 0.34) return CupertinoIcons.speaker_1_fill;
  if (volume < 0.67) return CupertinoIcons.speaker_2_fill;
  return CupertinoIcons.speaker_3_fill;
}
