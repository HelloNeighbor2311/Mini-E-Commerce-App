import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/variation_bottom_sheet.dart';
import 'cart_screen.dart';

/// Full product detail screen with:
/// - Hero image transition from HomeScreen
/// - Horizontal image slider (multiple angles)
/// - Price / name / tags block
/// - Variations row → opens BottomSheet
/// - Expandable description
/// - Fixed bottom action bar (Chat | Cart | "Them vao gio" | "Mua ngay")
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _imagePageController;
  int _currentImageIndex = 0;
  bool _descExpanded = false;

  // Pre-computed description once
  late final String _description = _buildDescription(widget.product.id);

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmt(int value) => '${NumberFormat('#,##0', 'vi_VN').format(value)}d';

  static String _buildDescription(String id) =>
      '''Sản phẩm #$id thuộc dòng cao cấp, được sản xuất từ chất liệu nguyên sinh tự nhiên, thân thiện với môi trường. Thiết kế hiện đại phù hợp nhiều phong cách thời trang.

  • Chất liệu: Cotton 100% nguyên chất, thoáng mát, thấm mồ hôi tốt
  • Kiểu dáng: Regular fit — không quá rộng cũng không quá chật
  • Độ bền: Bền màu sau nhiều lần giặt, không bị xù lông
  • Ứng dụng: Đi làm, đi chơi, du lịch, tập thể dục

  Hướng dẫn sử dụng: Giặt bằng nước lạnh / ấm dưới 40°C. Không sử dụng máy sấy. Phơi trong bóng mát để bảo vệ màu sắc và chất liệu vải.

  Bảo hành: Đổi / trả trong vòng 30 ngày nếu có lỗi nhà sản xuất. Miễn phí vận chuyển khi đổi trả hàng.''';

  // ── BottomSheet launcher ────────────────────────────────────────────────────

  void _openVariationSheet({required bool buyNow}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VariationBottomSheet(
        product: widget.product,
        buyNow: buyNow,
        onConfirm: (String size, String color, int qty) async {
          // Add to cart via Provider
          await context.read<CartProvider>().addProduct(
            widget.product,
            quantity: qty,
            size: size,
            color: color,
          );
          if (!context.mounted) return;
          Navigator.pop(context); // close sheet
          if (buyNow) {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã thêm $qty sản phẩm vào giỏ hàng!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF388E3C),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0.5,
            surfaceTintColor: Colors.transparent,
            title: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            actions: <Widget>[
              Consumer<CartProvider>(
                builder: (BuildContext context, CartProvider cart, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                      ),
                      if (cart.distinctItemCount > 0)
                        Positioned(
                          right: 4,
                          top: 2,
                          child: _CartBadge(count: cart.distinctItemCount),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Image slider ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: <Widget>[
                  PageView.builder(
                    controller: _imagePageController,
                    onPageChanged: (int i) =>
                        setState(() => _currentImageIndex = i),
                    itemCount: product.imageUrls.length,
                    itemBuilder: (BuildContext context, int index) {
                      Widget img = Image.network(
                        product.imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF2F2F2),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 56,
                            color: Colors.black38,
                          ),
                        ),
                      );

                      // Hero only on the first image to match ProductCard tag
                      if (index == 0) {
                        img = Hero(
                          tag: 'product-hero-${product.id}',
                          child: img,
                        );
                      }
                      return img;
                    },
                  ),

                  // Image counter badge (top-right)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${product.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Dot indicators (bottom-center)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        product.imageUrls.length,
                        (int i) {
                          final bool active = i == _currentImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 16 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFFF5722)
                                  : Colors.white60,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Price & Name block ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        _fmt(product.price),
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _fmt(product.originalPrice),
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: product.tags.map((String tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0EC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFFF5722).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFFFF5722),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ─────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 10,
                thickness: 10,
                color: Color(0xFFF5F5F5),
              ),
            ),
          ),

          // ── Variations row ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () => _openVariationSheet(buyNow: false),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: const <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Phân loại hàng',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Chọn kích cỡ, màu sắc',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Divider ─────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Divider(height: 10, thickness: 10, color: Color(0xFFF5F5F5)),
          ),

          // ── Expandable description ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _DescriptionBlock(
                description: _description,
                expanded: _descExpanded,
                onToggle: () => setState(() => _descExpanded = !_descExpanded),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // ── Fixed bottom action bar ────────────────────────────────────────
      bottomNavigationBar: _BottomActionBar(
        onAddToCart: () => _openVariationSheet(buyNow: false),
        onBuyNow: () => _openVariationSheet(buyNow: true),
        onGoCart: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const CartScreen()),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  final String description;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    const TextStyle bodyStyle = TextStyle(
      fontSize: 13,
      color: Colors.black87,
      height: 1.65,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Mô tả sản phẩm',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: Text(
            description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: bodyStyle,
          ),
          secondChild: Text(description, style: bodyStyle),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  expanded ? 'Thu gọn' : 'Xem thêm',
                  style: const TextStyle(
                    color: Color(0xFFFF5722),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFFFF5722),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onGoCart,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onGoCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: <Widget>[
          // Left half: Chat + Cart icons
          _IconAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: () {},
          ),
          const SizedBox(width: 6),
          Consumer<CartProvider>(
            builder: (BuildContext context, CartProvider cart, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _IconAction(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Giỏ hàng',
                    onTap: onGoCart,
                  ),
                  if (cart.distinctItemCount > 0)
                    Positioned(
                      right: 2,
                      top: 0,
                      child: _CartBadge(count: cart.distinctItemCount),
                    ),
                ],
              );
            },
          ),

          // Divider
          Container(
            height: 36,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.black12,
          ),

          // Right half: action buttons
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF0EC),
                      foregroundColor: const Color(0xFFFF5722),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Thêm vào giỏ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mua ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 22, color: Colors.black54),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
