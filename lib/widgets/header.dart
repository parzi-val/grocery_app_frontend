import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const Header({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.home, size: 30), // Icon for the product page
        onPressed: () {
          // Navigate to the product page
          Navigator.pushNamed(context, '/');
        },
      ),
      actions: [
        ...widget.actions!,
        IconButton(
          icon: Icon(Icons.shopping_cart, size: 30), // Cart icon
          onPressed: () {
            // Navigate to the cart page
            Navigator.pushNamed(context, '/cart');
          },
        ),
        // Conditional widget based on login status
        isLoggedIn
            ? TextButton(
                onPressed: () {
                  // Navigate to the profile page
                  Navigator.pushNamed(context, '/profile');
                },
                child: Icon(
                  Icons.account_circle, // Profile icon
                  size: 30, // Set the size of the icon
                  color: Colors.black, // Set the color if needed
                ),
              )
            : TextButton(
                onPressed: () {
                  // Navigate to the login page
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.black),
                ),
              ),
      ],
    );
  }
}
