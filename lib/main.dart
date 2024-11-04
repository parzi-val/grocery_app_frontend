import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/auth/profile_page.dart';
import 'screens/product_page.dart';
import 'screens/cart_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'utils/not_found_page.dart'; // Create a NotFoundPage
import 'widgets/product.dart';
import 'utils/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Grocery App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Color.fromRGBO(0, 106, 103, 1),
      ),
      routerConfig: _router,
    );
  }
}

bool isAuthenticated() {
  // Replace this with your actual authentication check
  return false; // Assume false for simplicity
}

bool isAdmin() {
  // Replace this with your actual admin check
  return false; // Assume false for simplicity
}

final GoRouter _router = GoRouter(
  redirect: (context, state) async {
    final isLoggedIn = await Auth.isAuthenticated();
    final isAdmin = await Auth.isAdmin();
    final isGoingToProtectedRoute = state.matchedLocation == '/profile' ||
        state.matchedLocation == '/admin/dashboard';
    final isGoingToAdminRoute = state.matchedLocation == '/admin/dashboard';

    if (!isLoggedIn && isGoingToProtectedRoute) {
      return '/login'; // Redirect to login if trying to access a protected route without authentication
    }

    if (isGoingToAdminRoute && !isAdmin) {
      return '/404'; // Redirect to 404 if not an admin
    }

    return null; // No redirection
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProductPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/product',
      builder: (context, state) => IndiProductPage(),
    ),
    GoRoute(
      path: '/404',
      builder: (context, state) => const NotFoundPage(), // 404 Page
    ),
  ],
);
