import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cart_line_item.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.items});

  final List<CartLineItem> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _submitting = false;

  int get _total =>
      widget.items.fold<int>(0, (int sum, CartLineItem e) => sum + e.lineTotal);

  String _fmt(int value) => '${NumberFormat('#,##0', 'vi_VN').format(value)}d';

  @override
  void initState() {
    super.initState();
    _addressController.text = '123 Duong ABC, Quan 1, TP.HCM';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final String address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap dia chi nhan hang')),
      );
      return;
    }

    if (widget.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong co san pham de thanh toan')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final OrderProvider orderProvider = context.read<OrderProvider>();
      final CartProvider cartProvider = context.read<CartProvider>();

      await orderProvider.placeOrder(
        selectedItems: widget.items,
        address: address,
        paymentMethod: _paymentMethod,
      );

      await cartProvider.removeItems(
        widget.items.map((CartLineItem e) => e.key),
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Dat hang thanh cong'),
            content: const Text('Don hang cua ban da duoc tao thanh cong.'),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: widget.items.isEmpty
          ? const Center(child: Text('Khong co san pham da chon'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
              children: <Widget>[
                _SectionCard(
                  title: 'Dia chi nhan hang',
                  child: TextField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Nhap dia chi cu the',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'Phuong thuc thanh toan',
                  child: Column(
                    children: <Widget>[
                      RadioListTile<String>(
                        value: 'COD',
                        groupValue: _paymentMethod,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                        title: const Text('COD - Thanh toan khi nhan hang'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        value: 'Momo',
                        groupValue: _paymentMethod,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                        title: const Text('Momo - Vi dien tu'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SectionCard(
                  title: 'San pham da chon (${widget.items.length})',
                  child: Column(
                    children: widget.items.map((CartLineItem item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Size ${item.size}, Mau ${item.color} x${item.quantity}',
                        ),
                        trailing: Text(
                          _fmt(item.lineTotal),
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Tong thanh toan',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    _fmt(_total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _submitting ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Dat hang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
