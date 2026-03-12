import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cart_line_item.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';
import 'order_history_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _fmt(int value) => '${NumberFormat('#,##0', 'vi_VN').format(value)}d';

  Future<bool> _confirmDelete(BuildContext context, CartLineItem item) async {
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xoa san pham?'),
          content: Text('Ban co muon xoa ${item.product.name} khoi gio hang?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Khong'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
              child: const Text('Xoa'),
            ),
          ],
        );
      },
    );
    return accepted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gio hang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (BuildContext context, CartProvider cart, _) {
          final List<CartLineItem> items = cart.items;

          if (items.isEmpty) {
            return const _EmptyCart();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final CartLineItem item = items[index];

              return Dismissible(
                key: ValueKey<String>(item.key),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(context, item),
                onDismissed: (_) {
                  context.read<CartProvider>().removeItem(item.key);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Da xoa san pham khoi gio')),
                  );
                },
                child: _CartItemTile(item: item, fmt: _fmt),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (BuildContext context, CartProvider cart, _) {
          final bool hasItems = cart.items.isNotEmpty;
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
            padding: EdgeInsets.fromLTRB(
              12,
              10,
              12,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: hasItems ? cart.allSelected : false,
                  onChanged: hasItems
                      ? (bool? value) {
                          cart.toggleSelectAll(value ?? false);
                        }
                      : null,
                ),
                const Text(
                  'Chon tat ca',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      'Tong thanh toan',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      _fmt(cart.selectedTotalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: cart.selectedTotalAmount > 0
                        ? () {
                            final List<CartLineItem> selected = cart
                                .selectedItems
                                .toList(growable: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => CheckoutScreen(items: selected),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mua hang'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.fmt});

  final CartLineItem item;
  final String Function(int) fmt;

  Future<void> _onDecreasePressed(BuildContext context) async {
    final CartProvider cart = context.read<CartProvider>();
    if (item.quantity > 1) {
      await cart.decreaseQuantity(item.key);
      return;
    }

    final bool? remove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('So luong se ve 0'),
          content: const Text('Ban co muon xoa san pham khoi gio hang?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Khong'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
              child: const Text('Xoa'),
            ),
          ],
        );
      },
    );

    if (remove == true) {
      await cart.removeItem(item.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: item.selected,
              onChanged: (bool? value) {
                context.read<CartProvider>().toggleItemSelected(
                  item.key,
                  value ?? false,
                );
              },
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 76,
                  height: 76,
                  color: const Color(0xFFF2F2F2),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phan loai: Size ${item.size}, Mau ${item.color}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          fmt(item.product.price),
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => _onDecreasePressed(context),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () {
                          context.read<CartProvider>().increaseQuantity(
                            item.key,
                          );
                        },
                      ),
                    ],
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Ink(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(
              Icons.remove_shopping_cart_outlined,
              size: 72,
              color: Colors.black38,
            ),
            SizedBox(height: 12),
            Text(
              'Gio hang dang trong',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Hay them san pham de tiep tuc mua sam.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
