import 'dart:io';
import 'dart:math';
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

  static String temporaryFile({String extension = '.tmp'}) {
    Directory tempPath = Directory.systemTemp;
    int randomId = 100000000 + Random().nextInt(9999999);
    return p.join(tempPath.path, '$randomId$extension');
  }
}
