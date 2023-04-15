import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/track.dart';

const String kBootStrapMessage = 'bootstrap';
const String kStopMessage = 'stop';
const String kCompleteMessage = 'done';

bool _scanInProgress = false;
bool _stopRequested = false;

bool isScanRunning() {
  return _scanInProgress;
}

void stopScan() {
  _stopRequested = true;
}

Future<bool> runScan(
  String rootFolder,
  TraxDatabase database,
  Function onUpdate,
  Function onComplete,
) async {
  // no double
  if (_scanInProgress) {
    return false;
  }

  // we need this
  final TagLib tagLib = TagLib();

  // a new start
  _stopRequested = false;
  _scanInProgress = true;

  // we need a parser
  List<String> queue = [];
  bool scanCompleted = false;
  final Worker parser = Worker();
  await parser.init(
    (message, mainToParserPort) async {
      //
      // here we receive messages sent by parser
      // using parserToMainPort.send(...)
      //

      void checkCompletion() {
        if (_stopRequested || (scanCompleted && queue.isEmpty)) {
          _scanInProgress = false;
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
          mainToParserPort,
          () {
            scanCompleted = true;
            checkCompletion();
          },
        );
      } else if (message == kCompleteMessage) {
        scanCompleted = true;
      } else {
        bool newArtist = await mainHandler(
          tagLib,
          database,
          message,
          null,
          null,
          [],
        );
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

  // all good
  return true;
}

Future<void> createScanner(
  TraxDatabase database,
  TagLib tagLib,
  List<String> queue,
  String rootFolder,
  SendPort mainToParserPort,
  Function onComplete,
) async {
  Worker scanner = Worker();
  await scanner.init(
    (message, mainToScannerPort) {
      //
      // here we receive messages sent by scanner
      // using scannerToMainPort.send(...)
      //

      if (message == kCompleteMessage) {
        onComplete();
      } else {
        mainHandler(
          tagLib,
          database,
          message,
          mainToScannerPort,
          mainToParserPort,
          queue,
        );
      }
    },
    directoryScanner,
    initialMessage: {
      'rootFolder': rootFolder,
      'files': await database.files(),
    },
  );
}

Future<bool> mainHandler(
  TagLib tagLib,
  TraxDatabase database,
  dynamic message,
  SendPort? mainToScannerPort,
  SendPort? mainToParserPort,
  List<String> queue,
) async {
  // handle stop requests
  if (_stopRequested) {
    mainToScannerPort?.send(kStopMessage);
    mainToParserPort?.send(kStopMessage);
    queue.clear();
    return false;
  }

  // make sure this is a command
  if (message is Map == false || message.containsKey('command') == false) {
    return false;
  }

  // now run it
  switch (message['command']) {
    case 'check':
      if (await checkFile(database, tagLib, message['filename'])) {
        queue.add(message['filename']);
        mainToParserPort?.send(message['filename']);
        return true;
      } else {
        return false;
      }
    case 'insert':
      Track track = message['track'] as Track;
      if (track.tags != null && track.tags!.valid) {
        bool newArtist = !(await database.artistExists(track.tags!.artist));
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

Future<bool> checkFile(
  TraxDatabase database,
  TagLib tagLib,
  String filename,
) async {
  // check if cached version is up-to-date
  Track? cached = await database.getTrack(filename);
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
  dynamic message,
  SendPort scannerToMainPort,
  SendErrorFunction onSendError,
) async {
  //
  // here we receive messages sent by main
  // using mainToParser.send(...)
  //

  // if stop command
  if (message == kStopMessage) {
    _stopRequested = true;
    return;
  }

  // first check given files
  List<String> files = message['files'];
  for (String filename in files) {
    // if stopped
    if (_stopRequested) {
      break;
    }
    File f = File(filename);
    if ((await f.exists()) == false) {
      scannerToMainPort.send({'command': 'delete', 'filename': filename});
    } else {
      // send this to allow stop
      scannerToMainPort.send('');
    }
  }

  // stopped?
  if (_stopRequested) {
    scannerToMainPort.send(kCompleteMessage);
    return;
  }

  // list directories
  Directory dir = Directory(message['rootFolder']);
  Stream<FileSystemEntity> lister = dir.list(recursive: true);
  late StreamSubscription<FileSystemEntity> subscription;
  subscription = lister.listen(
    (FileSystemEntity file) {
      if (_stopRequested) {
        scannerToMainPort.send(kCompleteMessage);
        subscription.cancel();
        return;
      }
      if (file is File && Track.isTrack(file.path)) {
        //print('checking ${file.path}');
        scannerToMainPort.send({'command': 'check', 'filename': file.path});
      }
    },
    cancelOnError: true,
    onError: (_) => scannerToMainPort.send(kCompleteMessage),
    onDone: () => scannerToMainPort.send(kCompleteMessage),
  );
}

void mediaParser(
  dynamic message,
  SendPort parserToMainPort,
  SendErrorFunction onSendError,
) {
  //
  // here we receive messages sent by main
  // using mainToParser.send(...)
  //

  // init
  if (message == kBootStrapMessage) {
    parserToMainPort.send(kBootStrapMessage);
    return;
  }

  // if not stopped
  if (_stopRequested) {
    return;
  }

  // if stop command
  if (message == kStopMessage) {
    _stopRequested = true;
    return;
  }

  // message is a queue
  String filename = message;
  //log('start parsing $filename');
  TagLib tagLib = TagLib();
  Track track = Track.parse(filename, tagLib);
  parserToMainPort.send({'command': 'insert', 'track': track});
  //print('done parsing $filename');
}
