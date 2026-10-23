import 'dart:ui' show Brightness, Color;

import 'package:characters/characters.dart';

/// Words that do not count when deriving initials from a multi-word name.
const Set<String> _kStopWords = {
  'the',
  'and',
  '&',
  'of',
  'et',
  'le',
  'la',
  'les',
  'de',
  'des',
  'du',
  'a',
  'al',
  'el',
};

/// "AC/DC" -> "AC", "AaRON" -> "Aa", "Adam and the Ants" -> "AA",
/// "The Alan Parsons Project" -> "AP", "Angus & Julia Stone" -> "AJ".
String artistInitials(String name) {
  final String trimmed = name.trim();
  if (trimmed.isEmpty) return '?';

  final List<String> words =
      trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  // a single token (even "AC/DC"): its first two characters as written
  if (words.length == 1) {
    final List<String> chars = words.first.characters.toList();
    return chars.take(2).join();
  }

  final List<String> significant =
      words.where((w) => !_kStopWords.contains(w.toLowerCase())).toList();
  final List<String> source = significant.isEmpty ? words : significant;
  if (source.length == 1) {
    // "Al Green": the article is dropped, so keep two letters of what is left
    final List<String> chars = source.first.characters.toList();
    return chars.first.toUpperCase() + chars.skip(1).take(1).join();
  }
  return source.take(2).map((w) => w.characters.first.toUpperCase()).join();
}

/// Soft background / strong foreground pairs, one set per brightness.
const List<List<Color>> _kLightPairs = [
  [Color(0xFFDCD2F5), Color(0xFF3A2A73)],
  [Color(0xFFF6D9CC), Color(0xFF7A2E14)],
  [Color(0xFFCBE9E4), Color(0xFF14514C)],
  [Color(0xFFF5D2E4), Color(0xFF7A1F4F)],
  [Color(0xFFE1EBC2), Color(0xFF44521A)],
  [Color(0xFFCFDDF4), Color(0xFF1F3F73)],
];

const List<List<Color>> _kDarkPairs = [
  [Color(0xFF3A2F5C), Color(0xFFD9CCFF)],
  [Color(0xFF5A3328), Color(0xFFFFD0BC)],
  [Color(0xFF1F4A47), Color(0xFFBFF0EA)],
  [Color(0xFF5A2F4A), Color(0xFFFFC9E6)],
  [Color(0xFF3F4A22), Color(0xFFE3F2B5)],
  [Color(0xFF2F3F5E), Color(0xFFC6DBFF)],
];

/// Same artist, same colors, on every launch.
int monogramIndex(String name) {
  int hash = 0x811c9dc5; // FNV-1a
  for (final int unit in name.trim().toLowerCase().codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash % _kLightPairs.length;
}

class MonogramColors {
  final Color background;
  final Color foreground;
  const MonogramColors(this.background, this.foreground);
}

MonogramColors monogramColors(String name, Brightness brightness) {
  final List<List<Color>> pairs =
      brightness == Brightness.dark ? _kDarkPairs : _kLightPairs;
  final List<Color> pair = pairs[monogramIndex(name)];
  return MonogramColors(pair[0], pair[1]);
}
