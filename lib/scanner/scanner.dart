import 'dart:io';
import 'dart:isolate';
import 'package:easy_isolate/easy_isolate.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/data/database.dart';

import '../model/track.dart';

void runScan(String rootFolder, TraxDatabase database) async {
  final TagLib tagLib = TagLib();
  final Worker worker = Worker();
  await worker.init(
    (data, isolateSendPort) {
      // check expected message
      if (data is Map == false || data.containsKey('command') == false) {
        return;
      }

      // now process command
      switch (data['command']) {
        case 'update':
          checkFile(database, tagLib, data['filename']);
          return;
        // case 'insert':
        //   Track track = data['track'] as Track;
        //   database.insert(track);
        //   return;
        case 'delete':
          String filename = data['filename'] as String;
          database.delete(filename);
          return;
      }
    },
    isolateHandler,
    initialMessage: {
      'rootFolder': rootFolder,
      'files': database.files(),
      //'databaseFile': databaseFile,
    },
  );
}

bool checkFile(TraxDatabase database, TagLib tagLib, String filename) {
  // check if cached version is up-to-date
  Track? cached = database.getTrack(filename);
  if (cached != null) {
    Track track = Track.parse(filename, null);
    if (track.filesize == cached.filesize &&
        track.lastModified == cached.lastModified) {
      return false;
    }
  }

  // parse
  //print('parsing $filename');
  Track track = Track.parse(filename, tagLib);
  database.insert(track);
  return true;
}

void isolateHandler(
    dynamic data, SendPort mainSendPort, SendErrorFunction onSendError) async {
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
      mainSendPort.send({'command': 'update', 'filename': file.path});
    }
  });
}
