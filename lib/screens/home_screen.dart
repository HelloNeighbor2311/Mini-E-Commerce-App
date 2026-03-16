import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/mock_product_service.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid_scroller.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _pageSize = 10;

  final MockProductService _service = MockProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _products = <Product>[];
  int _currentPage = 1;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  double _offset = 0;
  
  //THÊM BIẾN NÀY ĐỂ LƯU TRẠNG THÁI LỌC
  String _selectedCategory = 'all';
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isCollapsed => _offset > 18;

  Future<void> _loadFirstPage() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _currentPage = 1;
      _hasMore = true;
    });

    // 👉 TRUYỀN CATEGORY FILTER VÀO API
    final List<Product> firstPage = await _service.fetchProducts(
      page: _currentPage,
      pageSize: _pageSize,
      categoryFilter: _selectedCategory,
      searchKeyword: _searchKeyword, 
    );

    if (!mounted) return;

    setState(() {
      _products
        ..clear()
        ..addAll(firstPage);
      _isRefreshing = false;
      _hasMore = firstPage.length == _pageSize;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isRefreshing || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final int nextPage = _currentPage + 1;
    // 👉 TRUYỀN CATEGORY FILTER VÀO API
    final List<Product> nextProducts = await _service.fetchProducts(
      page: nextPage,
      pageSize: _pageSize,
      categoryFilter: _selectedCategory,
      searchKeyword: _searchKeyword,
    );

    if (!mounted) return;

    setState(() {
      _currentPage = nextPage;
      _products.addAll(nextProducts);
      _isLoadingMore = false;
      _hasMore = nextProducts.length == _pageSize;
    });
  }

  void _onScroll() {
    final double currentOffset = _scrollController.offset;
    if (currentOffset != _offset) {
      setState(() {
        _offset = currentOffset;
      });
    }

    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 260) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: const Color(0xFFFF5722),
        onRefresh: _loadFirstPage,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              stretch: true,
              backgroundColor: _isCollapsed
                  ? const Color(0xFFFF5722)
                  : Colors.transparent,
              elevation: _isCollapsed ? 2 : 0,
              expandedHeight: 92,
              titleSpacing: 10,
              title: _SearchBar(
                controller: _searchController,
                onSearch: (String value) {
                  // Khi gõ xong và ấn Enter:
                  setState(() {
                    _searchKeyword = value;
                    _selectedCategory = 'all'; // Tự động bỏ lọc danh mục để ưu tiên tìm kiếm
                  });
                  _loadFirstPage(); // Xóa lưới cũ, gọi lại API với từ khóa mới
                  
                  // Cuộn xuống để xem kết quả
                  _scrollController.animateTo(
                    300, 
                    duration: const Duration(milliseconds: 300), 
                    curve: Curves.easeInOut,
                  );
                },
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  color: _isCollapsed ? Colors.white : Colors.black87,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Consumer<CartProvider>(
                    builder:
                        (
                          BuildContext context,
                          CartProvider cart,
                          Widget? child,
                        ) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const CartScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart_outlined),
                                color: _isCollapsed
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              if (cart.distinctItemCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 2,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      cart.distinctItemCount > 99
                                          ? '99+'
                                          : cart.distinctItemCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: BannerCarousel(images: MockProductService.bannerImages),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Danh mục nổi bật',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                      CategoryGridScroller(
                      categories: MockProductService.categories,
                      selectedCategoryTag: _selectedCategory,
                      onCategorySelected: (String tag) {
                        // Nếu bấm lại vào ô đang chọn -> Bỏ lọc, hiện tất cả
                        if (_selectedCategory == tag) {
                          setState(() => _selectedCategory = 'all');
                        } else {
                          // Nếu bấm vào ô mới -> Lọc theo ô đó
                          setState(() => _selectedCategory = tag);
                        }
                        
                        // Hiển thị vòng quay loading và tải lại danh sách
                        _loadFirstPage(); 
                        
                        // (Tùy chọn) Tự động cuộn xuống chỗ sản phẩm một chút cho đẹp
                        _scrollController.animateTo(
                          300, 
                          duration: const Duration(milliseconds: 300), 
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Gợi ý hôm nay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  final Product product = _products[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    onAddToCart: () async {
                      await context.read<CartProvider>().addProduct(product);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                      );
                    },
                  );
                }, childCount: _products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.63,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: _isLoadingMore,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
const _SearchBar({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSearch, // GỌI HÀM KHI NGƯỜI DÙNG ẤN ENTER/SEARCH
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
