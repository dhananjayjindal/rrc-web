import 'const.dart';
import 'app_logger.dart';

/// Ensure `sheets` is available in this scope (defined in constants.dart)
final sheets = SheetsApi(
  spreadsheetId: AppConfig.spreadsheetId,
  apiKey: AppConfig.apiKey,
);

Future<
  void
>
showAboutPopup(
  BuildContext context,
) async {
  appLogger.i(
    'showAboutPopup - opened',
  );

  final textTheme = Theme.of(
    context,
  ).textTheme;
  final colorScheme = Theme.of(
    context,
  ).colorScheme;

  String? lastUpdated;
  String? devName;

  try {
    // OPTIONAL: dynamic fetch from Sheets if you have meta data stored there
    final sheets = SheetsApi(
      spreadsheetId: AppConfig.spreadsheetId,
      apiKey: AppConfig.apiKey,
    );
    final metadate = await sheets.fetchAppMetaDate();
    final metaname = await sheets.fetchAppMetaName();
    appLogger.d(
      "meta - $metadate",
    ); // You’d implement this in SheetsApi
    appLogger.d(
      "meta - $metaname",
    ); // You’d implement this in SheetsApi
    lastUpdated = metadate;
    devName = metaname;
  } catch (
    e
  ) {
    // fallback to hardcoded
    appLogger.w(
      'showAboutPopup - failed to fetch lastUpdated, fallback used: $e',
    );
    // lastUpdated = updateDate; // fallback build date
    // devName = developerName;
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder:
        (
          BuildContext context,
        ) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            backgroundColor: colorScheme.surface,
            titlePadding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              8,
            ),
            contentPadding: const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              20,
            ),
            actionsPadding: const EdgeInsets.only(
              bottom: 12,
              right: 8,
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.shopping_bag,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  'Radhe Collection',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(
                  height: 8,
                ),
                _infoRow(
                  Icons.person_outline,
                  'Developer',
                  devName!,
                  textTheme,
                  colorScheme,
                ),
                _infoRow(
                  Icons.update_outlined,
                  'Last Updated',
                  lastUpdated!,
                  textTheme,
                  colorScheme,
                ),
                // _infoRow(Icons.numbers, 'Version', version, textTheme, colorScheme),
                const SizedBox(
                  height: 12,
                ),
                Center(
                  child: Text(
                    '© 2025 All rights reserved.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Center(
                  child: Text(
                    'Made with ❤️ in India',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.close,
                  ),
                  label: const Text(
                    'Close',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  onPressed: () {
                    appLogger.i(
                      'showAboutPopup - closed',
                    );
                    Navigator.of(
                      context,
                    ).pop();
                  },
                ),
              ),
            ],
          );
        },
  );
}

/// helper for info rows with icon + label + value
Widget
_infoRow(
  IconData icon,
  String label,
  String value,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 6.0,
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Show QR / UPI info in a bottom sheet
void
showQrCodePopup(
  BuildContext context,
) {
  appLogger.i(
    'showQrCodePopup - opened',
  );
  showModalBottomSheet<
    void
  >(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(
      context,
    ).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(
          20,
        ),
      ),
    ),
    builder:
        (
          BuildContext ctx,
        ) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  20 +
                  MediaQuery.of(
                    ctx,
                  ).viewInsets.bottom,
            ),
            child:
                FutureBuilder<
                  UpiData
                >(
                  future: sheets.fetchUpiData(),
                  builder:
                      (
                        context,
                        snapshot,
                      ) {
                        final theme = Theme.of(
                          context,
                        );
                        final textTheme = theme.textTheme;

                        // Error state
                        if (snapshot.hasError) {
                          appLogger.e(
                            'showQrCodePopup - fetchUpiData error: ${snapshot.error}',
                          );
                          return SizedBox(
                            height: 260,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 56,
                                  color: AppConfig.error,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'Failed to load payment info.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: AppConfig.error,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                FilledButton.tonal(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pop(),
                                  child: const Text(
                                    'Close',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Loading state
                        if (!snapshot.hasData) {
                          appLogger.d(
                            'showQrCodePopup - waiting for data',
                          );
                          return SizedBox(
                            height: 260,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppConfig.loadingIndicator,
                              ),
                            ),
                          );
                        }

                        // Data ready
                        final upiData = snapshot.data!;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title + close
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Scan to Pay / Contact',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConfig.whiteText,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                  tooltip: 'Close',
                                  onPressed: () {
                                    appLogger.i(
                                      'showQrCodePopup - closed via close button',
                                    );
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),

                            // QR card
                            Center(
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(
                                  14,
                                ),
                                color: theme.colorScheme.surface,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  padding: const EdgeInsets.all(
                                    12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      14,
                                    ),
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                    color: theme.colorScheme.surface,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                    child: appImage(
                                      upiData.qrImageUrl,
                                      fit: BoxFit.contain, // keeps your “no cropping” behavior
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            // UPI ID + actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'UPI ID: ${upiData.upiId}',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppConfig.whiteText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 20,
                                  ),
                                  tooltip: 'Copy UPI ID',
                                  color: AppConfig.whiteText,
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: upiData.upiId,
                                      ),
                                    );
                                    appLogger.i(
                                      'showQrCodePopup - UPI ID copied: ${upiData.upiId}',
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'UPI ID copied to clipboard!',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        );
                      },
                ),
          );
        },
  );
}
