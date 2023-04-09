import 'dart:io';
import 'dart:isolate';
import 'package:easy_isolate/easy_isolate.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/data/database.dart';

import '../model/track.dart';

void runScan(String rootFolder, TraxDatabase database) async {
  final Worker worker = Worker();
  await worker.init(
    (data, isolateSendPort) {
      if (data is Map && data.containsKey('command')) {
        String command = data['command'];
        if (command == 'insert') {
          Track track = data['track'] as Track;
          database.insert(track);
        } else if (command == 'delete') {
          String filename = data['filename'] as String;
          database.delete(filename);
        }
      }
    },
    isolateHandler,
  );

  // now send data
  worker.sendMessage({
    'rootFolder': rootFolder,
    'files': database.files(),
    //'databaseFile': databaseFile,
  });
}

void isolateHandler(
    dynamic data, SendPort mainSendPort, SendErrorFunction onSendError) async {
  // we need a taglib
  TagLib tagLib = TagLib();

  // first check given files
  List<String> files = data['files'];
  for (String filename in files) {
    File f = File(filename);
    if ((await f.exists()) == false) {
      mainSendPort.send({'command': 'delete', 'filename': filename});
    }
  }

  // list directories
  Directory dir = Directory(data['rootFolder']);
  var lister = dir.list(recursive: true);
  lister.listen((file) {
    if (file is File && Track.isTrack(file.path)) {
      Track t = Track.parse(file.path, tagLib);
      mainSendPort.send({'command': 'insert', 'track': t});
    }
  });
}
