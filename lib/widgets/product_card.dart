import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  String _formatPrice(int value) {
    final NumberFormat formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(value)}₫';
  }

  String _formatSold(int soldCount) {
    if (soldCount >= 1000) {
      return 'Đã bán ${(soldCount / 1000).toStringAsFixed(1)}k';
    }
    return 'Đã bán $soldCount';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Đổ bóng nhẹ giúp Card trông cao cấp hơn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PHẦN HÌNH ẢNH
                AspectRatio(
                  aspectRatio: 1, // Giữ ảnh luôn vuông
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: 'product-hero-${product.id}',
                          child: Image.network(
                            product.imageUrls.first, // Sử dụng ảnh đầu tiên trong mảng
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(color: Colors.grey[100]);
                            },
                          ),
                        ),
                      ),
                      // Tag giảm giá/Mall ở góc trái
                      if (product.tags.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5722),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              product.tags.first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. PHẦN NỘI DUNG TÊN & GIÁ
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Hiển thị giá và nút thêm giỏ hàng trên cùng 1 hàng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Giá khuyến mãi
                                Text(
                                  _formatPrice(product.price),
                                  style: const TextStyle(
                                    color: Color(0xFFEE4D2D), // Màu đỏ Shopee
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Giá gốc (gạch ngang) nếu có
                                Text(
                                  _formatPrice(product.originalPrice),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Nút thêm giỏ hàng được thiết kế lại
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5722).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 18,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Phần thông tin phụ (Số lượng đã bán)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "5.0", // Giả lập rating
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 10, color: Colors.grey[300]),
                          const SizedBox(width: 8),
                          Text(
                            _formatSold(product.soldCount),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}