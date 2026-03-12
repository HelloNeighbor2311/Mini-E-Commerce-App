import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_commerce_app/main.dart';
import 'package:mini_commerce_app/providers/cart_provider.dart';
import 'package:mini_commerce_app/providers/order_provider.dart';

void main() {
  testWidgets('Home screen renders discover section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MiniCommerceApp(
        cartProvider: CartProvider(),
        orderProvider: OrderProvider(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Gợi ý hôm nay'), findsOneWidget);
    expect(find.text('Danh mục nổi bật'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
