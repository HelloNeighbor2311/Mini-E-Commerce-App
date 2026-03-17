import 'package:flutter/foundation.dart';

import '../config/app_data_config.dart';
import '../models/cart_line_item.dart';
import '../models/order_item.dart';
import '../services/firestore_order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({FirestoreOrderService? firestoreOrderService})
    : _firestoreOrderService = firestoreOrderService ?? FirestoreOrderService();

  final FirestoreOrderService _firestoreOrderService;
  final List<OrderItem> _orders = <OrderItem>[];
  bool _isLoading = false;

  List<OrderItem> get orders => List<OrderItem>.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    if (!AppDataConfig.useFirebase) {
      _orders.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<OrderItem> remoteOrders = await _firestoreOrderService
          .fetchOrders();
      _orders
        ..clear()
        ..addAll(remoteOrders);
    } catch (e) {
      debugPrint('Không thể tải đơn hàng từ Firebase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    if (AppDataConfig.useFirebase) {
      try {
        await _firestoreOrderService.saveOrder(order);
      } catch (e) {
        debugPrint('Không thể sync đơn hàng lên Firebase: $e');
      }
    }

    return order;
  }
}
