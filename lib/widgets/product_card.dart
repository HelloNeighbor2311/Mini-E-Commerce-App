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
    return '${formatter.format(value)}d';
  }

  String _formatSold(int soldCount) {
    if (soldCount >= 1000) {
      return 'Da ban ${(soldCount / 1000).toStringAsFixed(1)}k';
    }
    return 'Da ban $soldCount';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Hero(
                        tag: 'product-hero-${product.id}',
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (
                            BuildContext ctx,
                            Widget child,
                            ImageChunkEvent? progress,
                          ) {
                            if (progress == null) return child;
                            return Container(color: Colors.black12);
                          },
                          errorBuilder: (
                            BuildContext ctx,
                            Object error,
                            StackTrace? st,
                          ) {
                            return Container(
                              color: const Color(0xFFF2F2F2),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.black45,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (product.tags.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.tags.first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _formatPrice(product.price),
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _formatSold(product.soldCount),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onAddToCart,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.add_shopping_cart,
                        size: 18,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
