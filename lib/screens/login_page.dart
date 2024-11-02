import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery_frontend/widgets/header.dart'; // Adjust the path based on your project structure

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  dynamic roleInfo;

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:5000/api/auth/login'), // Update with your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];

      final roleResponse = await http
          .get(Uri.parse('http://localhost:5000/api/auth/role'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (roleResponse.statusCode == 200) {
        roleInfo = json.decode(roleResponse.body)['userType'];
        final userType = roleInfo?.toString() ?? "customer";
        // Store JWT in local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', token);
        await prefs.setString('role', userType);
      }
      if (roleInfo == 'admin') {
        Navigator.pushNamed(context, '/admin/dashboard');
      } else {
        Navigator.pushNamed(context, '/');
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: 300, // Set a fixed width for the login form
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                      ),
                      child: Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      appBar: Header(
        title: 'Login', // You can set the title for the header
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              // Action when help icon is pressed
            },
          ),
        ],
      ),
    );
  }
}
