import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/path_utils.dart';

enum ImportFileOp { copy, move }

abstract class PreferencesBase {
  String get musicFolder;
}

class Preferences extends ChangeNotifier implements PreferencesBase {
  static Preferences of(BuildContext context) {
    return Provider.of<Preferences>(context, listen: false);
  }

  late SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  // ignore: unnecessary_overrides
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  String get musicFolder {
    return _prefs.getString('musicfolder') ?? SystemPath.music() ?? '/Music';
  }

  set musicFolder(String folder) {
    _prefs.setString('musicfolder', folder);
  }

  ImportFileOp get importFileOp {
    return ImportFileOp.values.elementAt(_prefs.getInt('importfileop') ?? 0);
  }

  set importFileOp(ImportFileOp importFileOp) {
    _prefs.setInt('importfileop', importFileOp.index);
  }

  bool get keepMediaOrganized {
    return _prefs.getBool('keeporganized') ?? true;
  }

  set keepMediaOrganized(bool keepOrganized) {
    _prefs.setBool('keeporganized', keepOrganized);
  }

  Rect get windowBounds {
    try {
      var bounds = _prefs.getString('bounds');
      var parts = bounds?.split(',');
      var left = double.parse(parts![0]);
      var top = double.parse(parts[1]);
      var right = double.parse(parts[2]);
      var bottom = double.parse(parts[3]);
      return Rect.fromLTRB(left, top, right, bottom);
    } catch (_) {
      return const Rect.fromLTWH(0, 0, 800, 600);
    }
  }

  set windowBounds(Rect rc) {
    _prefs.setString('bounds',
        '${rc.left.toStringAsFixed(1)},${rc.top.toStringAsFixed(1)},${rc.right.toStringAsFixed(1)},${rc.bottom.toStringAsFixed(1)}');
  }

  Alignment getDialogAlignment(String preferenceKey) {
    try {
      var alignment = _prefs.getString(preferenceKey);
      var parts = alignment?.split(',');
      var x = double.parse(parts![0]);
      var y = double.parse(parts[1]);
      return Alignment(x, y);
    } catch (_) {
      return Alignment.center;
    }
  }

  void saveEditorAlignment(String preferenceKey, Alignment alignment) {
    _prefs.setString(preferenceKey,
        '${alignment.x.toStringAsFixed(1)},${alignment.y.toStringAsFixed(1)}');
  }
}
