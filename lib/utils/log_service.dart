import 'package:logger/logger.dart';

class LogService {
  static final Logger _logger = Logger(
    printer: SimplePrinter(printTime: true, colors: true),
  );

  // Log a message with various severity levels
  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message) => _logger.e(message);
  static void wtf(String message) => _logger.wtf(message);
}
