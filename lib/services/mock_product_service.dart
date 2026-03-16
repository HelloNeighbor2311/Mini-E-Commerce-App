import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class MockProductService {
  static const List<String> bannerImages = <String>[
    'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=1200&q=80',
  ];

  static const List<Map<String, String>> categories = <Map<String, String>>[
    {'title': 'Điện thoại', 'icon': 'smartphone', 'tag': 'smartphones'},
    {'title': 'Laptop', 'icon': 'laptop_mac', 'tag': 'laptops'},
    {'title': 'Mỹ phẩm', 'icon': 'face_retouching_natural', 'tag': 'skincare'},
    {'title': 'Trang trí', 'icon': 'home', 'tag': 'home-decoration'},
    {'title': 'Đồ nữ', 'icon': 'checkroom', 'tag': 'womens-dresses'},
    {'title': 'Đồ nam', 'icon': 'dry_cleaning', 'tag': 'mens-shirts'},
    {'title': 'Giày dép', 'icon': 'directions_run', 'tag': 'mens-shoes'},
    {'title': 'Đồng hồ', 'icon': 'watch', 'tag': 'mens-watches'},
    {'title': 'Trang sức', 'icon': 'diamond', 'tag': 'womens-jewellery'},
    {'title': 'Xe cộ', 'icon': 'directions_car', 'tag': 'automotive'},
  ];

  // Gọi DummyJSON API có hỗ trợ phân trang chuẩn xác
  Future<List<Product>> fetchProducts({
    required int page,
    required int pageSize,
    String? categoryFilter, // Thêm biến này để sau này truyền Tag vào lọc
    String? searchKeyword,
  }) async {
    try {
      // Tính toán vị trí bỏ qua (skip) cho tính năng cuộn tải thêm
      final int skip = (page - 1) * pageSize;
      String url;
      
      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        // Ưu tiên 1: Nếu người dùng đang gõ tìm kiếm -> Gọi API Search
        url = 'https://dummyjson.com/products/search?q=$searchKeyword&limit=$pageSize&skip=$skip';
      } else if (categoryFilter != null && categoryFilter != 'all') {
        // Ưu tiên 2: Lọc theo danh mục (nếu không tìm kiếm)
        url = 'https://dummyjson.com/products/category/$categoryFilter?limit=$pageSize&skip=$skip';
      } else {
        // Mặc định: Lấy tất cả
        url = 'https://dummyjson.com/products?limit=$pageSize&skip=$skip';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> productsList = data['products'];

        return productsList.map((json) {
          // Xử lý giá tiền: DummyJSON là tiền Đô ($), nhân 24k ra VNĐ
          double usdPrice = json['price'].toDouble();
          int vndPrice = (usdPrice * 24000).toInt();
          
          // Tính giá gốc dựa trên % giảm giá API trả về
          double discount = json['discountPercentage'].toDouble();
          int originalPrice = (vndPrice / (1 - (discount / 100))).toInt();

          return Product(
            id: json['id'].toString(),
            name: json['title'], 
            price: vndPrice,
            originalPrice: originalPrice,
            
            // DummyJSON cho hẳn một list ảnh, lấy luôn cho xịn
            imageUrls: List<String>.from(json['images']), 
            
            // Ép cái Category của API thành Tag hiển thị trên UI
            tags: [
              json['category'].toString().toUpperCase(), // Ném danh mục thành Tag
              'Giảm ${discount.toInt()}%' // Tag giảm giá chuẩn
            ], 
            soldCount: json['stock'] * 12, // Fake số lượng đã bán dựa trên tồn kho
          );
        }).toList();
      }
    } catch (e) {
      print('Lỗi fetch DummyJSON API: $e');
    }
    return <Product>[];
  }
}