import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'cart_product_quantities';
  final Map<String, int> _quantities = <String, int>{};

  Map<String, int> get quantities => Map<String, int>.unmodifiable(_quantities);

  int get distinctItemCount => _quantities.length;

  Future<void> loadFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_storageKey) ?? <String>[];
    _quantities
      ..clear()
      ..addEntries(
        raw.map((String item) {
          final List<String> parts = item.split(':');
          final String id = parts.first;
          final int quantity =
              int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
          return MapEntry<String, int>(id, quantity);
        }),
      );
    notifyListeners();
  }

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    final int current = _quantities[product.id] ?? 0;
    _quantities[product.id] = current + quantity;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = _quantities.entries
        .map((MapEntry<String, int> e) => '${e.key}:${e.value}')
        .toList();
    await prefs.setStringList(_storageKey, raw);
  }
}
