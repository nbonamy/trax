import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SystemPath {
  static String? home() {
    switch (Platform.operatingSystem) {
      case 'linux':
        return Platform.environment['HOME'];
      case 'macos':
        return p.join('/Users', Platform.environment['USER']);
      case 'windows':
        return Platform.environment['USERPROFILE'];
      case 'android':
        // Probably want internal storage.
        return '/storage/sdcard0';
      default:
        return null;
    }
  }

  static String? music() {
    String? home = SystemPath.home();
    if (home == null) return null;
    return p.join(home, 'Music');
  }

  static String? desktop() {
    String? home = SystemPath.home();
    if (home == null) return null;
    return p.join(home, 'Desktop');
  }

  static Future<Directory> appData() {
    return getApplicationSupportDirectory();
  }

  static Future<String> dbFile() async {
    Directory appDataDir = await appData();
    return p.join(appDataDir.path, 'trax.db');
  }

  static Future<String> artistCacheFile() async {
    Directory appDataDir = await appData();
    return p.join(appDataDir.path, 'artists.cache');
  }

  static String temporaryFile({String extension = '.tmp'}) {
    Directory tempPath = Directory.systemTemp;
    int randomId = 100000000 + Random().nextInt(9999999);
    return p.join(tempPath.path, '$randomId$extension');
  }
}

class PathUtils {
  static void deleteEmptyFolder(String startingFolder, String stopAtFolder) {
    Directory dir = Directory(startingFolder);
    while (true) {
      if (dir.existsSync() == false) break;
      if (FileSystemEntity.identicalSync(dir.path, stopAtFolder)) break;
      if (dir.isEmptySync() == false) break;
      dir.listSync().forEach((element) {
        element.deleteSync();
      });
      dir.deleteSync();
      Directory parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
  }
}

extension IsEmpty on Directory {
  bool isEmptySync() {
    // general case
    List<FileSystemEntity> items = listSync(followLinks: false);
    if (items.isEmpty) return true;

    // special cases
    if (Platform.operatingSystem == 'macos') {
      if (items.length > 1) return false;
      FileSystemEntity item = items.first;
      if (item is File && p.basename(item.path) == '.DS_Store') {
        return true;
      }
    }

    // too bad
    return false;
  }
}
