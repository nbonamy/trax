
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SystemPath {
  static String? home() {
    switch (Platform.operatingSystem) {
      case 'linux':
      case 'macos':
        return Platform.environment['HOME'];
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

  static String getFolderNamedAsset(String? dirpath, {bool isDrive = false}) {
    if (isDrive) {
      return 'assets/img/folders/drive.png';
    } else if (dirpath != null) {
      var basename = p.basename(dirpath).toLowerCase();
      if ([
        'applications',
        'desktop',
        'documents',
        'downloads',
        'dropbox',
        'movies',
        'music',
        'pictures',
      ].contains(basename)) {
        return 'assets/img/folders/$basename.png';
      }
    }

    // default
    return 'assets/img/folders/default.png';
  }
}
