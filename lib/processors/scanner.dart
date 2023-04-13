import 'dart:io';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/track.dart';

const String kBootStrapMessage = 'bootstrap';
const String kCompleteMessage = 'done';

void runScan(
  String rootFolder,
  TraxDatabase database,
  Function onUpdate,
  Function onComplete,
) async {
  final TagLib tagLib = TagLib();

  // we need a parser
  List<String> queue = [];
  bool scanCompleted = false;
  final Worker parser = Worker();
  await parser.init(
    (message, parserSendPort) async {
      void checkCompletion() {
        if (scanCompleted && queue.isEmpty) {
          onComplete();
        }
      }

      // now we can start the scanner
      if (message == kBootStrapMessage) {
        await createScanner(
          database,
          tagLib,
          queue,
          rootFolder,
          parserSendPort,
          () {
            scanCompleted = true;
            checkCompletion();
          },
        );
      } else if (message == kCompleteMessage) {
        scanCompleted = true;
      } else {
        bool newArtist = mainHandler(tagLib, database, message, null, []);
        queue.remove(message['track'].filename);
        if (newArtist) {
          onUpdate();
        }
      }
      checkCompletion();
    },
    mediaParser,
    initialMessage: kBootStrapMessage,
  );
}

Future<void> createScanner(
  TraxDatabase database,
  TagLib tagLib,
  List<String> queue,
  String rootFolder,
  SendPort parserSendPort,
  Function onComplete,
) async {
  Worker scanner = Worker();
  await scanner.init(
    (message, scannerSendPort) {
      if (message == kCompleteMessage) {
        onComplete();
      } else {
        mainHandler(
          tagLib,
          database,
          message,
          parserSendPort,
          queue,
        );
      }
    },
    directoryScanner,
    initialMessage: {
      'rootFolder': rootFolder,
      'files': database.files(),
    },
  );
}

bool mainHandler(
  TagLib tagLib,
  TraxDatabase database,
  dynamic message,
  SendPort? parserSendPort,
  List<String> queue,
) {
  if (message is Map == false || message.containsKey('command') == false) {
    return false;
  }

  switch (message['command']) {
    case 'check':
      if (checkFile(database, tagLib, message['filename'])) {
        queue.add(message['filename']);
        parserSendPort?.send(message['filename']);
        return true;
      } else {
        return false;
      }
    case 'insert':
      Track track = message['track'] as Track;
      if (track.tags != null && track.tags!.valid) {
        bool newArtist = !database.artistExists(track.tags!.artist);
        database.insert(track, notify: false);
        return newArtist;
      } else {
        return false;
      }
    case 'delete':
      String filename = message['filename'] as String;
      database.delete(filename);
      return false;
    default:
      return false;
  }
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
  return true;
}

void directoryScanner(
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
  lister.listen(
    (file) {
      if (file is File && Track.isTrack(file.path)) {
        //print('checking ${file.path}');
        mainSendPort.send({'command': 'check', 'filename': file.path});
      }
    },
    onDone: () => mainSendPort.send(kCompleteMessage),
  );
}

void mediaParser(
    dynamic message, SendPort mainSendPort, SendErrorFunction onSendError) {
  if (message == kBootStrapMessage) {
    mainSendPort.send(kBootStrapMessage);
    return;
  }

  // message is a queue
  String filename = message;
  //log('start parsing $filename');
  TagLib tagLib = TagLib();
  Track track = Track.parse(filename, tagLib);
  mainSendPort.send({'command': 'insert', 'track': track});
  //print('done parsing $filename');
}
