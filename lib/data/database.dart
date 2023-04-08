import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:trax/utils/path.dart';

class TraxDatabase extends ChangeNotifier {
  late Database _database;

  static TraxDatabase of(BuildContext context) {
    return Provider.of<TraxDatabase>(context, listen: false);
  }

  TraxDatabase() {}

  Future<void> init() async {
    String dbFile = await SystemPath.dbFile();
    _database = sqlite3.open(dbFile);
  }
}
