import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/auth/profile_page.dart';
import 'screens/product_page.dart';
import 'screens/cart_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/order_details_page.dart';
import 'utils/not_found_page.dart';
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

final GoRouter _router = GoRouter(
  redirect: (context, state) async {
    final isLoggedIn = await Auth.isAuthenticated();
    final isAdmin = await Auth.isAdmin();
    final isGoingToProtectedRoute =
        state.subloc == '/profile' || state.subloc == '/admin/dashboard';
    final isGoingToAdminRoute = state.subloc == '/admin/dashboard';

    if (!isLoggedIn && isGoingToProtectedRoute) {
      return '/login';
    }

    if (isGoingToAdminRoute && !isAdmin) {
      return '/404';
    }

    return null;
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
      path: '/products/:productId',
      builder: (context, state) {
        final productId = state.params['productId']!;
        return IndiProductPage(productId: productId);
      },
    ),
    GoRoute(
      path: '/404',
      builder: (context, state) => const NotFoundPage(),
    ),
    GoRoute(
      path: '/order/:orderId',
      builder: (context, state) {
        final orderId = state.params['orderId']!;
        return OrderDetailsPage(orderId: orderId);
      },
    ),
  ],
);
