import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_line_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'cart_line_items_v2';

  final Map<String, CartLineItem> _items = <String, CartLineItem>{};

  List<CartLineItem> get items =>
      List<CartLineItem>.unmodifiable(_items.values);

  int get distinctItemCount => _items.length;

  bool get allSelected =>
      _items.isNotEmpty && _items.values.every((CartLineItem e) => e.selected);

  int get selectedTotalAmount => _items.values
      .where((CartLineItem e) => e.selected)
      .fold<int>(0, (int sum, CartLineItem e) => sum + e.lineTotal);

  List<CartLineItem> get selectedItems => _items.values
      .where((CartLineItem e) => e.selected)
      .toList(growable: false);

  String _lineKey(String productId, String size, String color) {
    return '$productId|$size|$color';
  }

  Future<void> loadFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_storageKey) ?? <String>[];

    _items.clear();

    for (final String item in raw) {
      if (item.contains('{')) {
        try {
          final Map<String, dynamic> json =
              jsonDecode(item) as Map<String, dynamic>;
          final CartLineItem line = CartLineItem.fromJson(json);
          _items[line.key] = line;
          continue;
        } catch (_) {
          // Fallback to legacy format below.
        }
      }

      final List<String> parts = item.split(':');
      final String id = parts.first;
      final int quantity = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
      final Product fallbackProduct = Product(
        id: id,
        name: 'San pham $id',
        price: 0,
        originalPrice: 0,
        imageUrls: const <String>[
          'https://picsum.photos/seed/fallback/300/300',
        ],
        tags: const <String>[],
        soldCount: 0,
      );
      final String key = _lineKey(id, 'M', 'Xanh');
      _items[key] = CartLineItem(
        key: key,
        product: fallbackProduct,
        size: 'M',
        color: 'Xanh',
        quantity: quantity,
        selected: true,
      );
    }

    notifyListeners();
  }

  Future<void> addProduct(
    Product product, {
    int quantity = 1,
    String size = 'M',
    String color = 'Xanh',
  }) async {
    final String key = _lineKey(product.id, size, color);
    final CartLineItem? current = _items[key];

    if (current == null) {
      _items[key] = CartLineItem(
        key: key,
        product: product,
        size: size,
        color: color,
        quantity: quantity,
        selected: true,
      );
    } else {
      _items[key] = current.copyWith(
        product: product,
        quantity: current.quantity + quantity,
      );
    }

    notifyListeners();
    await _persist();
  }

  Future<void> toggleItemSelected(String key, bool value) async {
    final CartLineItem? line = _items[key];
    if (line == null) {
      return;
    }
    _items[key] = line.copyWith(selected: value);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleSelectAll(bool value) async {
    final List<String> keys = _items.keys.toList();
    for (final String key in keys) {
      _items[key] = _items[key]!.copyWith(selected: value);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> increaseQuantity(String key) async {
    final CartLineItem? line = _items[key];
    if (line == null) {
      return;
    }
    _items[key] = line.copyWith(quantity: line.quantity + 1);
    notifyListeners();
    await _persist();
  }

  Future<void> decreaseQuantity(String key) async {
    final CartLineItem? line = _items[key];
    if (line == null) {
      return;
    }
    if (line.quantity <= 1) {
      await removeItem(key);
      return;
    }
    _items[key] = line.copyWith(quantity: line.quantity - 1);
    notifyListeners();
    await _persist();
  }

  Future<void> removeItem(String key) async {
    _items.remove(key);
    notifyListeners();
    await _persist();
  }

  Future<void> removeItems(Iterable<String> keys) async {
    for (final String key in keys) {
      _items.remove(key);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = _items.values
        .map((CartLineItem e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, raw);
  }
}
