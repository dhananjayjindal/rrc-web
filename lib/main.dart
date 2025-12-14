import 'app_logger.dart';
import 'const.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void
main() {
    if (kIsWeb) {
    // ignore: undefined_prefixed_name
    // This is safe on web
    setUrlStrategy(
      const HashUrlStrategy(),
    );
  }
  // Catch ALL uncaught async + framework errors
  runZonedGuarded<
    Future<
      void
    >
  >(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Flutter framework errors
      FlutterError.onError =
          (
            FlutterErrorDetails details,
          ) {
            appLogger.e(
              'FLUTTER FRAMEWORK ERROR',
              error: details.exception,
              stackTrace: details.stack,
            );
          };

      appLogger.i(
        'App starting → loading cart from storage',
      );

      // Create and hydrate Cart BEFORE running app
      final cart = Cart();
      await cart.loadFromPrefs(); // 🔥 required for web refresh

      runApp(
        ChangeNotifierProvider<
          Cart
        >.value(
          value: cart,
          child: const MyApp(),
        ),
      );
    },
    (
      error,
      stack,
    ) {
      // Any uncaught Dart errors
      appLogger.e(
        'UNCAUGHT DART ERROR',
        error: error,
        stackTrace: stack,
      );
    },
  );
}

/// ─────────────────────────────────────────────
/// ROOT APP
/// ─────────────────────────────────────────────
class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  // REQUIRED BREAKPOINTS (AS REQUESTED)
  bool
  isWeb(
    BuildContext context,
  ) =>
      MediaQuery.of(
        context,
      ).size.width >=
      700;

  bool
  isPhone(
    BuildContext context,
  ) =>
      MediaQuery.of(
        context,
      ).size.width <=
      700;

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radhe Collection',

      // Theme can be refined later per platform
      theme: ThemeData.dark(),

      // Use builder to access MediaQuery safely
      builder:
          (
            context,
            child,
          ) {
            // Example usage of breakpoint logic (safe place)
            final bool web = isWeb(
              context,
            );
            appLogger.d(
              'App running on ${web ? "WEB" : "PHONE"}',
            );

            return child!;
          },

      home: const LoadingScreen(),
    );
  }
}
