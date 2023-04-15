import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:taglib_ffi/taglib_ffi.dart';

import '../data/database.dart';
import '../model/track.dart';
import '../utils/logger.dart';

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
  Logger logger,
  String rootFolder,
  TraxDatabase database,
  Function onUpdate,
  Function onComplete,
) async {
  // no double
  if (_scanInProgress) {
    logger.w('[SCAN] Scan already in progress');
    return false;
  }

  // log
  logger.i('[SCAN] Starting new scan');

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
          logger.i('[SCAN] Scan completion detected');
          _scanInProgress = false;
          onComplete();
        }
      }

      // now we can start the scanner
      if (message == kBootStrapMessage) {
        await createScanner(
          logger,
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
        bool newArtist = await commandHandler(
          logger,
          tagLib,
          database,
          message,
          null,
          null,
          [],
        );
        queue.remove(message['track'].filename);
        if (newArtist) {
          logger.d('[SCAN] new artist inserted');
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
  Logger logger,
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
        commandHandler(
          logger,
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

Future<bool> commandHandler(
  Logger logger,
  TagLib tagLib,
  TraxDatabase database,
  dynamic message,
  SendPort? mainToScannerPort,
  SendPort? mainToParserPort,
  List<String> queue,
) async {
  // handle stop requests
  if (_stopRequested) {
    logger.i('[SCAN] Stop scan requested');
    mainToScannerPort?.send(kStopMessage);
    mainToParserPort?.send(kStopMessage);
    queue.clear();
    return false;
  }

  // dummy message
  if (message == '') {
    return false;
  }

  // make sure this is a command
  if (message is Map == false || message.containsKey('command') == false) {
    logger.w('[SCAN] Invalid command received');
    return false;
  }

  // now run it
  switch (message['command']) {
    case 'info':
      String logMessage = message['message'];
      logger.i('[SCAN] $logMessage');
      return false;

    case 'perf':
      String label = message['label'] ?? message['message'];
      logger.perf(label);
      return false;

    case 'check':
      String filename = message['filename'];
      logger.v('[SCAN] Checking file updated: $filename');
      if (await checkFile(database, tagLib, filename)) {
        logger.v('[SCAN] File requires parsing: $filename');
        queue.add(filename);
        mainToParserPort?.send(filename);
        return true;
      } else {
        return false;
      }

    case 'insert':
      Track track = message['track'] as Track;
      if (track.tags != null && track.tags!.valid) {
        logger.v('[SCAN] Updating track: ${track.filename}');
        bool newArtist = !(await database.artistExists(track.tags!.artist));
        database.insert(track, notify: false);
        return newArtist;
      } else {
        return false;
      }

    case 'delete':
      String filename = message['filename'] as String;
      logger.v('[SCAN] Deleting track: $filename');
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

  // perf
  scannerToMainPort.send({
    'command': 'perf',
    'label': 'Checking deleted files',
  });

  // first check given files for deletion

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

  // perf
  scannerToMainPort.send({
    'command': 'perf',
    'label': 'Checking deleted files',
  });

  // stopped?
  if (_stopRequested) {
    scannerToMainPort.send(kCompleteMessage);
    return;
  }

  // info
  scannerToMainPort.send({
    'command': 'perf',
    'message': 'Listing music folder contents',
  });

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
        scannerToMainPort.send({'command': 'check', 'filename': file.path});
      }
    },
    cancelOnError: true,
    onError: (_) {
      scannerToMainPort.send({
        'command': 'perf',
        'message': 'Listing music folder contents',
      });
      scannerToMainPort.send(kCompleteMessage);
    },
    onDone: () {
      scannerToMainPort.send({
        'command': 'perf',
        'message': 'Listing music folder contents',
      });
      scannerToMainPort.send(kCompleteMessage);
    },
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
