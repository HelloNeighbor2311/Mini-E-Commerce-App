import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/app_data_config.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppDataConfig.useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final cartProvider = CartProvider();
  await cartProvider.loadFromStorage();

  final orderProvider = OrderProvider();
  await orderProvider.fetchOrders();

  runApp(
    MiniCommerceApp(cartProvider: cartProvider, orderProvider: orderProvider),
  );
}

class MiniCommerceApp extends StatelessWidget {
  const MiniCommerceApp({
    super.key,
    required this.cartProvider,
    required this.orderProvider,
  });

  final CartProvider cartProvider;
  final OrderProvider orderProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
      ],
      child: MaterialApp(
        title: 'Mini Commerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5722)),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
