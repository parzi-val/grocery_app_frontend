import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading; // New parameter for custom leading action

  const Header({
    super.key,
    required this.title,
    required this.actions,
    this.leading, // Accept the custom leading widget
  });

  @override
  HeaderState createState() => HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HeaderState extends State<Header> {
  bool isLoggedIn = false;
  bool isCustomLeading = false; // New variable to check for custom leading
  bool admin = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkAdminStatus();
    // Use the correct syntax for conditional assignment
    isCustomLeading = widget.leading != null;
  }

  // Method to check if a JWT exists in local storage
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jwt =
        prefs.getString('jwt'); // Assuming you store JWT with key 'jwt'
    setState(() {
      isLoggedIn = jwt != null; // Set login status based on JWT presence
    });
  }

  // Method to check admin status from local storage
  Future<void> _checkAdminStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString('role'); // Read the role as a string
    setState(() {
      admin = role == 'admin'; // Check if the role is 'admin'
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      elevation: 0,
      backgroundColor:
          const Color.fromRGBO(0, 106, 103, 1), // Change to a shade of green
      foregroundColor: Colors.white, // Set foreground color for contrast
      leading: widget.leading ??
          IconButton(
            icon:
                Icon(admin ? Icons.admin_panel_settings : Icons.home, size: 30),
            onPressed: () {
              if (admin) {
                context.go('/admin/dashboard');
              } else {
                context.go('/');
              }
            },
          ),
      actions: [
        ...widget.actions!,
        isCustomLeading
            ? IconButton(
                icon: Icon(Icons.apps, size: 30), // Additional action icon
                onPressed: () {
                  context.go('/');
                  // Navigate to the product page
                },
              )
            : Container(),
        IconButton(
          icon: Icon(Icons.shopping_cart, size: 30), // Cart icon
          onPressed: () {
            context.go('/cart'); // Navigate to the cart page
          },
        ),
        isLoggedIn
            ? TextButton(
                onPressed: () {
                  context.go('/profile'); // Navigate to the profile page
                },
                child: Icon(
                  Icons.account_circle, // Profile icon
                  size: 30,
                  color: Colors.white, // Change icon color for contrast
                ),
              )
            : TextButton(
                onPressed: () {
                  context.go('/login'); // Navigate to the login page
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white), // Change text color for contrast
                ),
              ),
      ],
    );
  }
}
