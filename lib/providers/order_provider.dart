import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_line_item.dart';
import '../models/order_item.dart';

class OrderProvider extends ChangeNotifier {
  static const String _storageKey = 'orders_v1';

  final List<OrderItem> _orders = <OrderItem>[];

  List<OrderItem> get orders => List<OrderItem>.unmodifiable(_orders);

  Future<void> loadFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_storageKey) ?? <String>[];

    _orders
      ..clear()
      ..addAll(
        raw.map((String e) {
          final Map<String, dynamic> json =
              jsonDecode(e) as Map<String, dynamic>;
          return OrderItem.fromJson(json);
        }),
      );

    notifyListeners();
  }

  List<OrderItem> byStatus(OrderStatus status) {
    return _orders.where((OrderItem e) => e.status == status).toList();
  }

  Future<OrderItem> placeOrder({
    required List<CartLineItem> selectedItems,
    required String address,
    required String paymentMethod,
  }) async {
    final DateTime now = DateTime.now();
    final String id = 'DH${now.microsecondsSinceEpoch}';

    final OrderItem order = OrderItem(
      id: id,
      createdAt: now,
      address: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      items: selectedItems,
    );

    _orders.insert(0, order);
    notifyListeners();
    await _persist();
    return order;
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = _orders
        .map((OrderItem e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, raw);
  }
}
