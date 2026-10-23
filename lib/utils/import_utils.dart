import 'dart:io';

import 'package:path/path.dart' as p;

class ImportUtils {
  /// What the importer knows how to read.
  static const Set<String> kImportExtensions = {'.mp3', '.m4a', '.flac'};

  static bool isImportable(String filename) {
    // skip macOS resource forks
    if (p.basename(filename).startsWith('._')) return false;
    return kImportExtensions.contains(p.extension(filename).toLowerCase());
  }

  /// Expands dropped files and folders into the audio files they contain,
  /// folders first-level sorted so that albums keep their track order.
  static List<String> collectAudioFiles(List<String> paths) {
    final List<String> result = [];
    for (final String path in paths) {
      final FileSystemEntityType type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        final List<String> children = Directory(path)
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .map((f) => f.path)
            .where(isImportable)
            .toList()
          ..sort();
        result.addAll(children);
      } else if (type == FileSystemEntityType.file && isImportable(path)) {
        result.add(path);
      }
    }
    return result;
  }
}
