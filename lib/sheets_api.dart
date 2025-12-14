import 'package:http/http.dart' as http;
import 'app_logger.dart';
import 'const.dart';

// Model for UPI Data
class UpiData {
  final String qrImageUrl;
  final String upiId;

  UpiData(
    this.qrImageUrl,
    this.upiId,
  );
}

class SheetsApi {
  final String spreadsheetId;
  final String apiKey;

  SheetsApi({
    required this.spreadsheetId,
    required this.apiKey,
  });

  // ✅ Reusable private fetch helper
  Future<List<List<dynamic>>> _fetchRange(
    String tabName,
    String range,
  ) async {
    final url = "https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$tabName!$range?key=$apiKey";

    appLogger.d(
      "[SheetsApi] Fetching range: $tabName!$range",
    );
    appLogger.d(
      "[SheetsApi] URL: $url",
    );

    final response = await http.get(
      Uri.parse(
        url,
      ),
    );
    appLogger.d(
      "[SheetsApi] Response status: ${response.statusCode}",
    );

    if (response.statusCode != 200) {
      appLogger.e(
        "[SheetsApi] ❌ Failed request: ${response.body}",
      );
      throw Exception(
        "Failed to fetch data from $tabName!$range",
      );
    }

    final data = json.decode(
      response.body,
    );
    if (data["values"] == null || data["values"].isEmpty) {
      appLogger.e(
        "[SheetsApi] ⚠️ No data found in $tabName!$range",
      );
      throw Exception(
        "No data found at $tabName!$range",
      );
    }

    return List<List<dynamic>>.from(
      data["values"],
    );
  }

  // ✅ Generic helper for single-cell fetches
  Future<String> _fetchSingleCell(
    String tabName,
    String range,
  ) async {
    final values = await _fetchRange(
      tabName,
      range,
    );
    final value = values.first.first.toString();
    appLogger.d(
      "[SheetsApi] ✅ $tabName!$range = $value",
    );
    return value;
  }

  // 📦 Fetch product data
  Future<List<Product>> fetchProducts() async {
    const tabName = "Products";
    final url = "https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$tabName?key=$apiKey";
    appLogger.d(
      "[SheetsApi] Fetching products from $url",
    );

    final response = await http.get(
      Uri.parse(
        url,
      ),
    );
    if (response.statusCode != 200) {
      appLogger.e(
        "[SheetsApi] ❌ Failed to fetch products (${response.statusCode})",
      );
      throw Exception(
        "Failed to fetch products",
      );
    }

    final data = json.decode(
      response.body,
    );
    final rows = data["values"] as List<dynamic>;
    if (rows.isEmpty) return [];

    final headers = (rows[0] as List)
        .map(
          (
            e,
          ) =>
              e.toString(),
        )
        .toList();
    final products = <Product>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i] as List;
      if (row.length != headers.length) {
        continue;
      }
      final map = Map<String, dynamic>.fromIterables(
        headers,
        row,
      );
      products.add(
        Product.fromMap(
          map,
        ),
      );
    }

    appLogger.d(
      "[SheetsApi] ✅ ${products.length} products fetched successfully",
    );
    return products;
  }

  // 🖼️ Splash Screen GIF
  Future<String> fetchSplashUrl() async => _fetchSingleCell(
        "Splash",
        "A1:A1",
      );

  // 💬 WhatsApp Message
  Future<String> fetchWAMSG() async => _fetchSingleCell(
        "Splash",
        "A2:A2",
      );

  // 📞 Mobile Number
  Future<String> fetchNo() async => _fetchSingleCell(
        "Splash",
        "A3:A3",
      );

  // 💰 UPI QR & ID
  Future<UpiData> fetchUpiData() async {
    final values = await _fetchRange(
      "Splash",
      "A4:A5",
    );
    final qrImageUrl = values[0][0].toString();
    final upiId = values[1][0].toString();
    appLogger.d(
      "[SheetsApi] ✅ QR URL: $qrImageUrl | UPI ID: $upiId",
    );
    return UpiData(
      qrImageUrl,
      upiId,
    );
  }

  // 🆕 App version info
  Future<String> fetchLatestVersion() async => _fetchSingleCell(
        "Splash",
        "A6:A6",
      );

  // 🔗 Update download URL
  Future<String> fetchUpdateUrl() async => _fetchSingleCell(
        "Splash",
        "A7:A7",
      );
  // 📝 App meta information    
  Future<String> fetchAppMetaDate() async => _fetchSingleCell(
        "Splash",
        "A8:A8",
      );
  Future<String> fetchAppMetaName() async => _fetchSingleCell(
        "Splash",
        "A9:A9",
      );Future<String> fetchUpdateLogs() async => _fetchSingleCell(
        "Splash",
        "A10:A10",
      );

}

/// Universal image widget for CDN / GitHub / jsDelivr images
/// Safe for Flutter Web + Mobile
