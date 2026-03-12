import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cartProvider = CartProvider();
  await cartProvider.loadFromStorage();

  runApp(MiniCommerceApp(cartProvider: cartProvider));
}

class MiniCommerceApp extends StatelessWidget {
  const MiniCommerceApp({super.key, required this.cartProvider});

  final CartProvider cartProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
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
