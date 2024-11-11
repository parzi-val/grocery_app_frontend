import 'package:flutter/material.dart';
import 'package:grocery_frontend/screens/admin/monitoring_page.dart';
import 'package:grocery_frontend/screens/admin/products_page.dart';
import 'package:grocery_frontend/screens/admin/orders_page.dart';
import 'package:grocery_frontend/screens/admin/delivery_page.dart';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:grocery_frontend/globals.dart' as globals;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AnalyticsPage(),
    AdminProductPage(key: globals.adminProductPageKey),
    OrdersPage(),
    DeliveryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'Admin Dashboard',
        actions: [],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, size: 30),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(74, 98, 138, 1)),
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Monitoring'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Products'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Orders'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('Delivery'),
              onTap: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
