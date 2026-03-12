class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrls,
    required this.tags,
    required this.soldCount,
  });

  final String id;
  final String name;
  final int price;
  final int originalPrice;
  final List<String> imageUrls;
  final List<String> tags;
  final int soldCount;

  /// Convenience getter — first image used by ProductCard & BottomSheet thumbnail.
  String get imageUrl => imageUrls.first;

  Product copyWith({
    String? id,
    String? name,
    int? price,
    int? originalPrice,
    List<String>? imageUrls,
    List<String>? tags,
    int? soldCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      soldCount: soldCount ?? this.soldCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrls': imageUrls,
      'tags': tags,
      'soldCount': soldCount,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Support both legacy single-image and new multi-image format.
    final List<String> imgs = json.containsKey('imageUrls')
        ? (json['imageUrls'] as List<dynamic>).cast<String>()
        : <String>[json['imageUrl'] as String];
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      originalPrice: json['originalPrice'] as int,
      imageUrls: imgs,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      soldCount: json['soldCount'] as int,
    );
  }
}
