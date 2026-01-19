/// Simple logging utility for the Destiny Decoder application.
/// Provides centralized logging to replace print() statements.
library;

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  static const String _tag = 'DestinyDecoder';
  static LogLevel _level = LogLevel.debug;

  /// Set the minimum log level to display
  static void setLevel(LogLevel level) {
    _level = level;
  }

  /// Log a debug message
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Log an info message
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Log a warning message
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Log an error message
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(LogLevel level, String message, dynamic error, StackTrace? stackTrace) {
    if (level.index < _level.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final output = '[$timestamp] [$levelStr] $_tag: $message';

    // ignore: avoid_print
    print(output);

    if (error != null) {
      // ignore: avoid_print
      print('Error: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('Stack trace:\n$stackTrace');
    }
  }
}
