// lib/cart.dart
import 'app_logger.dart';
import 'const.dart';

const String _kCartStorageKey = 'radhe_cart_v1';

class CartItem {
  final String id;
  final String name;
  final double price;
  int qty;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    this.imageUrl,
  });

  double get total => price * qty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'qty': qty,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> m) {
    return CartItem(
      id: m['id'].toString(),
      name: m['name'].toString(),
      price: (m['price'] is num) ? (m['price'] as num).toDouble() : double.tryParse(m['price'].toString()) ?? 0.0,
      qty: (m['qty'] is int) ? m['qty'] as int : int.tryParse(m['qty'].toString()) ?? 0,
      imageUrl: m['imageUrl']?.toString(),
    );
  }
}

class Cart extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  SharedPreferences? _prefs;

  Cart();

  /// Call this once during app startup to load persisted cart.
  Future<void> loadFromPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(_kCartStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        _items.clear();
        decoded.forEach((key, value) {
          try {
            // value might be a Map already or JSON encoded string depending on previous state
            final map = (value is String) ? json.decode(value) as Map<String, dynamic> : value as Map<String, dynamic>;
            _items[key] = CartItem.fromMap(map);
          } catch (e, st) {
            appLogger.w('Cart.loadFromPrefs - failed to parse item $key: $e');
            appLogger.d('Stack: $st');
          }
        });
        appLogger.i('Cart.loadFromPrefs - loaded ${_items.length} distinct items, totalQty: $itemCount');
      } else {
        appLogger.d('Cart.loadFromPrefs - nothing stored');
      }
    } catch (e, st) {
      appLogger.e('Cart.loadFromPrefs - ERROR: $e');
      appLogger.d('Stack: $st');
    }
    notifyListeners(); // inform UI after load
  }

  Future<void> _saveToPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};
      _items.forEach((k, v) => data[k] = v.toMap());
      final encoded = json.encode(data);
      await _prefs!.setString(_kCartStorageKey, encoded);
      appLogger.d('Cart._saveToPrefs - saved ${_items.length} items');
    } catch (e, st) {
      appLogger.e('Cart._saveToPrefs - ERROR: $e');
      appLogger.d('Stack: $st');
    }
  }

  /// Number of items (sum of quantities)
  int get itemCount {
    final count = _items.values.fold<int>(0, (sum, it) => sum + it.qty);
    appLogger.d('Cart.itemCount getter -> $count');
    return count;
  }

  /// Number of distinct products
  int get distinctCount {
    final count = _items.length;
    appLogger.d('Cart.distinctCount getter -> $count');
    return count;
  }

  Map<String, CartItem> get items {
    return Map.unmodifiable(_items);
  }

  double get totalAmount {
    final total = _items.values.fold<double>(0.0, (sum, it) => sum + it.total);
    appLogger.d('Cart.totalAmount getter -> $total');
    return total;
  }

  double _parsePrice(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.parse(value.toString());
    } catch (e, st) {
      appLogger.w('Cart._parsePrice - failed parsing value: $value, defaulting to 0.0');
      appLogger.d('Stack: $st');
      return 0.0;
    }
  }

  Future<void> addItem(dynamic product, int qty) async {
    if (qty <= 0) {
      appLogger.w('Cart.addItem - called with non-positive qty ($qty). Ignoring.');
      return;
    }

    try {
      final id = product.id.toString();
      final name = product.name.toString();
      double price = 0.0;
      if (product.salePrice != null && product.salePrice.toString().isNotEmpty) {
        price = _parsePrice(product.salePrice);
      } else {
        price = _parsePrice(product.price);
      }

      final imageUrl = (product.imageUrl is List && (product.imageUrl as List).isNotEmpty) ? product.imageUrl.first.toString() : (product.imageUrl is String ? product.imageUrl as String : null);

      final prevQty = _items[id]?.qty ?? 0;
      appLogger.i('Cart.addItem called - id: $id, name: $name, addQty: $qty, prevQty: $prevQty, price: $price');

      if (_items.containsKey(id)) {
        _items[id]!.qty += qty;
        appLogger.d('Cart.addItem - item existed. prevQty: $prevQty, added: $qty, newQty: ${_items[id]!.qty}');
      } else {
        _items[id] = CartItem(id: id, name: name, price: price, qty: qty, imageUrl: imageUrl);
        appLogger.d('Cart.addItem - item created and added to _items map (id: $id, qty: $qty)');
      }

      notifyListeners();
      await _saveToPrefs();
      appLogger.i('Cart.addItem - notifyListeners and persisted (itemCount: $itemCount, distinctCount: $distinctCount)');
    } catch (e, st) {
      appLogger.e('Cart.addItem - ERROR while adding item: $e');
      appLogger.d('Cart.addItem - stack: $st');
    }
  }

  Future<void> increment(String id) async {
    try {
      appLogger.i('Cart.increment called - id: $id');
      if (!_items.containsKey(id)) {
        appLogger.w('Cart.increment - item not found (id: $id)');
        return;
      }
      final prev = _items[id]!.qty;
      _items[id]!.qty += 1;
      appLogger.d('Cart.increment - itemId: $id prevQty: $prev newQty: ${_items[id]!.qty}');
      notifyListeners();
      await _saveToPrefs();
    } catch (e, st) {
      appLogger.e('Cart.increment - ERROR: $e');
      appLogger.d('Cart.increment - stack: $st');
    }
  }

  Future<void> decrement(String id) async {
    try {
      appLogger.i('Cart.decrement called - id: $id');
      if (!_items.containsKey(id)) {
        appLogger.w('Cart.decrement - item not found (id: $id)');
        return;
      }
      final current = _items[id]!.qty;
      if (current <= 1) {
        appLogger.d('Cart.decrement - qty <= 1, removing item instead of decrementing (id: $id, current: $current)');
        await removeItem(id);
        return;
      }
      _items[id]!.qty = current - 1;
      appLogger.d('Cart.decrement - itemId: $id prevQty: $current newQty: ${_items[id]!.qty}');
      notifyListeners();
      await _saveToPrefs();
    } catch (e, st) {
      appLogger.e('Cart.decrement - ERROR: $e');
      appLogger.d('Cart.decrement - stack: $st');
    }
  }

  Future<void> removeItem(String id) async {
    try {
      final existed = _items.containsKey(id);
      appLogger.w('Cart.removeItem called - id: $id, existed: $existed');
      if (existed) {
        final removed = _items.remove(id);
        appLogger.i('Cart.removeItem - removed item: ${removed?.name} (id: $id). new distinctCount: $distinctCount, itemCount: $itemCount');
        notifyListeners();
        await _saveToPrefs();
      } else {
        appLogger.w('Cart.removeItem - item not found (id: $id)');
      }
    } catch (e, st) {
      appLogger.e('Cart.removeItem - ERROR: $e');
      appLogger.d('Cart.removeItem - stack: $st');
    }
  }

  Future<void> clear() async {
    try {
      final prevDistinct = _items.length;
      final prevTotalQty = itemCount;
      appLogger.w('Cart.clear - clearing all items (prevDistinct: $prevDistinct, prevTotalQty: $prevTotalQty)');
      _items.clear();
      notifyListeners();
      await _saveToPrefs();
      appLogger.i('Cart.clear - cart cleared successfully (now distinct: $distinctCount, itemCount: $itemCount)');
    } catch (e, st) {
      appLogger.e('Cart.clear - ERROR: $e');
      appLogger.d('Cart.clear - stack: $st');
    }
  }

  String toOrderString({String prefix = ''}) {
    final buffer = StringBuffer();
    if (prefix.isNotEmpty) buffer.writeln(prefix);
    for (final it in _items.values) {
      buffer.writeln('${it.qty} x ${it.name} - Rs ${it.price.toStringAsFixed(2)} = Rs ${it.total.toStringAsFixed(2)}');
    }
    buffer.writeln('Total: Rs ${totalAmount.toStringAsFixed(2)}');
    final orderText = buffer.toString();

    final preview = orderText.replaceAll('\n', ' | ').trim();
    final previewShort = preview.length > 400 ? '${preview.substring(0, 400)}... (truncated)' : preview;
    appLogger.d('Cart.toOrderString -> $previewShort');

    return orderText;
  }
}
