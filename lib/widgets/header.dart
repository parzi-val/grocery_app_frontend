import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const Header({
    super.key,
    required this.title,
    required this.actions,
    this.leading,
  });

  @override
  HeaderState createState() => HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HeaderState extends State<Header> {
  bool isLoggedIn = false;
  bool isCustomLeading = false;
  bool admin = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkAdminStatus();

    isCustomLeading = widget.leading != null;
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jwt = prefs.getString('jwt');
    setState(() {
      isLoggedIn = jwt != null;
    });
  }

  Future<void> _checkAdminStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString('role');
    setState(() {
      admin = role == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      elevation: 0,
      backgroundColor: const Color.fromRGBO(0, 106, 103, 1),
      foregroundColor: Colors.white,
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
                icon: Icon(Icons.apps, size: 30),
                onPressed: () {
                  context.go('/');
                },
              )
            : Container(),
        IconButton(
          icon: Icon(Icons.shopping_cart, size: 30),
          onPressed: () {
            context.go('/cart');
          },
        ),
        isLoggedIn
            ? TextButton(
                onPressed: () {
                  context.go('/profile');
                },
                child: Icon(
                  Icons.account_circle,
                  size: 30,
                  color: Colors.white,
                ),
              )
            : TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ],
    );
  }
}
