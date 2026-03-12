import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order_item.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Don mua'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: <Widget>[
              Tab(text: 'Cho xac nhan'),
              Tab(text: 'Dang giao'),
              Tab(text: 'Da giao'),
              Tab(text: 'Da huy'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _OrderStatusTab(status: OrderStatus.pending),
            _OrderStatusTab(status: OrderStatus.shipping),
            _OrderStatusTab(status: OrderStatus.delivered),
            _OrderStatusTab(status: OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusTab extends StatelessWidget {
  const _OrderStatusTab({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (BuildContext context, OrderProvider provider, _) {
        final List<OrderItem> orders = provider.byStatus(status);

        if (orders.isEmpty) {
          return const Center(
            child: Text('Chua co don hang trong trang thai nay'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          itemBuilder: (BuildContext context, int index) {
            final OrderItem order = orders[index];
            return _OrderCard(order: order);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: orders.length,
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderItem order;

  String _fmt(int value) => '${NumberFormat('#,##0', 'vi_VN').format(value)}d';

  String _fmtDate(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _fmtDate(order.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Thanh toan: ${order.paymentMethod}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            'Dia chi: ${order.address}',
            style: const TextStyle(color: Colors.black54),
          ),
          const Divider(height: 20),
          ...order.items.take(3).map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${e.product.name} - Size ${e.size}, Mau ${e.color} x${e.quantity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          if (order.items.length > 3)
            Text(
              '+${order.items.length - 3} san pham khac',
              style: const TextStyle(color: Colors.black54),
            ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Spacer(),
              Text(
                'Tong: ${_fmt(order.totalAmount)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
