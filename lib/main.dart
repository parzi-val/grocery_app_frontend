import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/product_page.dart';
import 'screens/cart_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/login': (context) => const LoginPage(), // Route to the Login Page
        '/': (context) => const ProductPage(), // Route to the Products Page
        '/cart': (context) => const CartPage(), // Route to the Cart Page
        '/profile': (context) =>
            const ProfilePage(), // Route to the Profile Page
      },
    );
  }
}
