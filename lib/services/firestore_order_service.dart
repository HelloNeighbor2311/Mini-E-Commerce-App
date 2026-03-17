import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_item.dart';

class FirestoreOrderService {
  FirestoreOrderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> saveOrder(OrderItem order) async {
    final Map<String, dynamic> payload = order.toJson();
    payload['createdAt'] = Timestamp.fromDate(order.createdAt);
    payload['totalAmount'] = order.totalAmount;

    await _firestore.collection('orders').doc(order.id).set(payload);
  }

  Future<List<OrderItem>> fetchOrders() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          return OrderItem.fromJson(doc.data());
        })
        .toList(growable: false);
  }
}
