import 'cart_line_item.dart';

enum OrderStatus { pending, shipping, delivered, cancelled }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.createdAt,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.items,
  });

  final String id;
  final DateTime createdAt;
  final String address;
  final String paymentMethod;
  final OrderStatus status;
  final List<CartLineItem> items;

  int get totalAmount =>
      items.fold<int>(0, (int sum, CartLineItem line) => sum + line.lineTotal);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'items': items.map((CartLineItem e) => e.toJson()).toList(),
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final String statusRaw = (json['status'] as String?) ?? 'pending';
    return OrderItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      address: json['address'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: OrderStatus.values.firstWhere(
        (OrderStatus e) => e.name == statusRaw,
        orElse: () => OrderStatus.pending,
      ),
      items: (json['items'] as List<dynamic>)
          .map((dynamic e) => CartLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
