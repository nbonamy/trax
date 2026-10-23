import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:trax/utils/import_utils.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('trax_import_test');
    File(p.join(root.path, 'album', '02 - b.flac'))
      ..createSync(recursive: true)
      ..writeAsStringSync('x');
    File(p.join(root.path, 'album', '01 - a.FLAC')).writeAsStringSync('x');
    File(p.join(root.path, 'album', 'disc2', '01 - c.mp3'))
      ..createSync(recursive: true)
      ..writeAsStringSync('x');
    File(p.join(root.path, 'album', 'cover.jpg')).writeAsStringSync('x');
    File(p.join(root.path, 'album', '._01 - a.flac')).writeAsStringSync('x');
    File(p.join(root.path, 'single.m4a')).writeAsStringSync('x');
    File(p.join(root.path, 'notes.txt')).writeAsStringSync('x');
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('knows what it can import', () {
    expect(ImportUtils.isImportable('/a/b.mp3'), isTrue);
    expect(ImportUtils.isImportable('/a/b.M4A'), isTrue);
    expect(ImportUtils.isImportable('/a/b.flac'), isTrue);
    expect(ImportUtils.isImportable('/a/b.wav'), isFalse);
    expect(ImportUtils.isImportable('/a/._b.mp3'), isFalse);
  });

  test('expands folders recursively and ignores everything else', () {
    final List<String> files = ImportUtils.collectAudioFiles([
      p.join(root.path, 'album'),
      p.join(root.path, 'single.m4a'),
      p.join(root.path, 'notes.txt'),
      p.join(root.path, 'missing.mp3'),
    ]);
    expect(
      files.map((f) => p.relative(f, from: root.path)).toList(),
      [
        p.join('album', '01 - a.FLAC'),
        p.join('album', '02 - b.flac'),
        p.join('album', 'disc2', '01 - c.mp3'),
        'single.m4a',
      ],
    );
  });
}
