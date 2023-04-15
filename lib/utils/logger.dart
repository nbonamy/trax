import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart' as publog;
import 'package:provider/provider.dart';

class Logger extends ChangeNotifier {
  static Logger of(BuildContext context) {
    return Provider.of<Logger>(context, listen: false);
  }

  late publog.Logger _logger;
  final Map<String, DateTime> _perfLogs = {};

  Logger() {
    _logger = publog.Logger(
      level: publog.Level.info,
      printer: publog.SimplePrinter(),
      output: null,
    );
  }

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }

  /// Log a message at level [Level.wtf].
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }

  /// Log a perf message:
  void perf(String label) {
    // 1st call: store start time
    if (_perfLogs.containsKey(label) == false) {
      _perfLogs[label] = DateTime.now();
      i('[PERF] Task "$label" started');
      return;
    }

    // 2nd call: log
    DateTime start = _perfLogs[label]!;
    DateTime end = DateTime.now();
    int duration = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    i('[PERF] Task "$label" completed in $duration ms');
    _perfLogs.remove(label);
  }
}
