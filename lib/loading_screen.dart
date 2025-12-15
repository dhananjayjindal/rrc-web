import 'const.dart';

class LoadingScreen
    extends
        StatefulWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  State<
    LoadingScreen
  >
  createState() => _LoadingScreenState();
}

class _LoadingScreenState
    extends
        State<
          LoadingScreen
        > {
  // ─────────────────────────────────────────────
  // REQUIRED BREAKPOINTS (AS REQUESTED)
  // ─────────────────────────────────────────────
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
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Replace this with real startup logic later:
  /// - load cart
  /// - fetch config
  /// - init services
  Future<
    void
  >
  _initializeApp() async {
    // Small delay to show branding / loading
    await Future.delayed(
      const Duration(
        seconds: 5,
      ),
    );

    if (!mounted) return;

    // Use pushReplacement to avoid back navigation
    Navigator.of(
      context,
    ).pushReplacement(
      MaterialPageRoute(
        builder:
            (
              _,
            ) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final double indicatorSize =
        isPhone(
          context,
        )
        ? 18
        : 48;
    final double textSize =
        isPhone(
          context,
        )
        ? 16
        : 18;

    return Scaffold(
      backgroundColor: AppConfig.loadingScreenColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'web/RC LOGO.png',
                height: 300,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading your app…  ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: indicatorSize,
                    height: indicatorSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<
                            Color
                          >(
                            Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
              if (isWeb(
                context,
              )) ...[
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Preparing everything for you',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
