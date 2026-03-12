import 'dart:async';

import '../models/product.dart';

class MockProductService {
  static const List<String> bannerImages = <String>[
    'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80',
  ];

  static const List<Map<String, String>> categories = <Map<String, String>>[
    {'title': 'Thoi trang', 'icon': 'checkroom'},
    {'title': 'Dien thoai', 'icon': 'smartphone'},
    {'title': 'My pham', 'icon': 'face_retouching_natural'},
    {'title': 'Gia dung', 'icon': 'kitchen'},
    {'title': 'Me va be', 'icon': 'child_care'},
    {'title': 'Bach hoa', 'icon': 'shopping_basket'},
    {'title': 'Laptop', 'icon': 'laptop_mac'},
    {'title': 'The thao', 'icon': 'sports_soccer'},
  ];

  static const int _totalProducts = 100;

  Future<List<Product>> fetchProducts({
    required int page,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));

    final int start = (page - 1) * pageSize;
    if (start >= _totalProducts) {
      return <Product>[];
    }

    final int end = (start + pageSize).clamp(0, _totalProducts);

    return List<Product>.generate(end - start, (int index) {
      final int id = start + index + 1;
      final int price = 79000 + (id * 3500);
      return Product(
        id: 'p$id',
        name: 'San pham hot trend #$id - chat lieu cao cap, mau dep, gia tot',
        price: price,
        originalPrice: price + 40000,
        imageUrls: <String>[
          'https://picsum.photos/seed/product${id}a/600/600',
          'https://picsum.photos/seed/product${id}b/600/600',
          'https://picsum.photos/seed/product${id}c/600/600',
          'https://picsum.photos/seed/product${id}d/600/600',
        ],
        tags: _tagByIndex(id),
        soldCount: 300 + (id * 12),
      );
    });
  }

  List<String> _tagByIndex(int index) {
    if (index % 5 == 0) {
      return <String>['Mall', 'Giam 50%'];
    }
    if (index % 3 == 0) {
      return <String>['Yeu thich'];
    }
    return <String>['Giao nhanh'];
  }
}
