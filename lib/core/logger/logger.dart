import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    // Number of method calls to be displayed
    errorMethodCount: 8,
    // Number of method calls if stacktrace is provided
    lineLength: 120,
    // Width of the output
    colors: true,
    // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
  ),
);

void logWarningOnly() {
  Logger.level = Level.warning;
}

/* 
Samples 

logger.t("Trace log");

logger.d("Debug log");

logger.i("Info log");

logger.w("Warning log");

logger.e("Error log", error: 'Test Error');

logger.f("What a fatal log", error: error, stackTrace: stackTrace);
 */
