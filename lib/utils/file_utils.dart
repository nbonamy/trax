import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import '../components/dialog.dart';
import 'platform_utils.dart';

class FileUtils {
  static Future confirmDelete(
    BuildContext context,
    List<String> files, {
    Color? barrierColor,
  }) {
    var t = AppLocalizations.of(context)!;
    String title = files.length == 1
        ? t.deleteTitleSingle(p.basename(files[0]))
        : t.deleteTitleMultiple(files.length);
    String text = t.deleteText(files.length);

    return TraxDialog.confirm(
      context: context,
      barrierColor: barrierColor,
      title: title,
      text: text,
      //isDestructive: true,
      confirmLabel: AppLocalizations.of(context)?.menuEditDeleteSoft,
      onConfirmed: (context) {
        delete(files).then((value) {
          Navigator.of(context).pop(true);
        }).onError((error, stackTrace) {
          Navigator.of(context).pop();
        });
      },
    );
  }

  static Future delete(List<String> files) {
    List<Future> futures = [];
    for (var file in files) {
      futures.add(PlatformUtils.moveToTrash(file));
    }
    return Future.wait(futures);
  }
}
