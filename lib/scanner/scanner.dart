import 'dart:async';
import 'dart:io';
import 'package:async_task/async_task.dart';
import 'package:taglib_ffi/taglib_ffi.dart';
import 'package:trax/data/database.dart';

import '../model/track.dart';

// This top-level function returns the tasks types that will be registered
// for execution. Task instances are returned, but won't be executed and
// will be used only to identify the task type:
List<AsyncTask> _taskTypeRegister() => [Scanner('')];

void runScan(String rootFolder) async {
  var task = Scanner(rootFolder);
  var asyncExexcutor = AsyncExecutor(
    taskTypeRegister: _taskTypeRegister,
  );
  asyncExexcutor.logger.enabled = true;
  var execution = asyncExexcutor.execute(task);
  //var channel = await task.channel();
  // while (!channel.isClosed) {}
  //await execution;
  // while (true) {
  //   var message = await channel!.waitMessage();
  //   print(message);
  // }
}

final AsyncTaskChannelMessageHandler messageHandler =
    (dynamic message, bool fromExecutingContext) {
  if (message != null) {
    print(message);
  }
};

class Message {
  final int totalFiles;
  final int processedFiles;

  Message(this.totalFiles, this.processedFiles);
}

class Scanner extends AsyncTask<String, void> {
  final String rootFolder;
  late TraxDatabase _database;
  late TagLib _tagLib;
  TagLib tagLib = TagLib();

  Scanner(this.rootFolder) {
    _tagLib = TagLib();
    _database = TraxDatabase();
  }

  @override
  AsyncTaskChannel? channelInstantiator() {
    return AsyncTaskChannel(messageHandler: messageHandler);
  }

  @override
  AsyncTask<String, void> instantiate(String parameters,
      [Map<String, SharedData>? sharedData]) {
    return Scanner(parameters);
  }

  @override
  String parameters() {
    return rootFolder;
  }

  @override
  FutureOr<void> run() {
    // get the resolved channel:
    //var channel = channelResolved()!;

    // list directories
    Directory dir = Directory(rootFolder);
    var lister = dir.list(recursive: true);
    lister.listen((file) {
      if (file is File && Track.isTrack(file.path)) {
        Track t = Track(file.path);
        t.parse(_tagLib);
      }
    });
  }
}
