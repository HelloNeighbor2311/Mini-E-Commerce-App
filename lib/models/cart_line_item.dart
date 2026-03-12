import 'product.dart';

class CartLineItem {
  const CartLineItem({
    required this.key,
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.selected,
  });

  final String key;
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final bool selected;

  int get lineTotal => product.price * quantity;

  CartLineItem copyWith({
    String? key,
    Product? product,
    String? size,
    String? color,
    int? quantity,
    bool? selected,
  }) {
    return CartLineItem(
      key: key ?? this.key,
      product: product ?? this.product,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'product': product.toJson(),
      'size': size,
      'color': color,
      'quantity': quantity,
      'selected': selected,
    };
  }

  factory CartLineItem.fromJson(Map<String, dynamic> json) {
    return CartLineItem(
      key: json['key'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size'] as String,
      color: json['color'] as String,
      quantity: json['quantity'] as int,
      selected: json['selected'] as bool? ?? true,
    );
  }
}
