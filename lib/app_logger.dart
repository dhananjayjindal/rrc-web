// lib/utils/app_logger.dart
import 'const.dart'; // your existing constants

// Configure a custom printer and filter
final Logger
appLogger = Logger(
  // Use PrettyPrinter to format the log output nicely
  printer: PrettyPrinter(
    // 1. More context for errors
    methodCount: 3, // Show 3 method calls leading up to the log
    errorMethodCount: 8, // Show a deeper stack trace for errors
    lineLength: 120, // Wider lines for better readability

    colors: true, // Keep colors for quick identification
    printEmojis: true, // Keep emojis for visual appeal
    dateTimeFormat: DateTimeFormat.dateAndTime, // show timestamp (default format used by logger)
    // NOTE: PrettyPrinter does not support `dateTimeFormat` directly in many versions.
  ),

  // Use a custom log filter to show logs only in debug mode
  filter: DevelopmentFilter(),
);

// Custom filter to hide logs in production
class DevelopmentFilter
    extends
        LogFilter {
  @override
  bool shouldLog(
    LogEvent event,
  ) {
    // Only allow logs if the app is running in debug mode
    // This prevents logs in release builds.
    return kDebugMode;
  }
}

// Usage examples:
// appLogger.t("trace message");
// appLogger.d("debug message");
// appLogger.i("info message");
// appLogger.w("warning message");
// appLogger.e("error message");
// appLogger.wtf("fatal/error leading to crash");
