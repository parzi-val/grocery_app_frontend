import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth {
  static dynamic roleInfo;

  static Future<void> login(
      BuildContext context, String email, String password) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:5000/api/auth/login'), // Update with your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
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
        context.go('/admin/dashboard');
      } else {
        context.go('/');
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed!')),
      );
    }
  }

  static Future<void> register(
      BuildContext context, String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:5000/api/auth/register'), // Update with your API endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'type': 'customer'
      }),
    );

    if (response.statusCode == 201) {
      // Registration successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
      context.go('/login');
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed!')),
      );
    }
  }

  static Future<String?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('jwt');
    return userToken;
  }

  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('jwt');
    return userToken != null;
  }

  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    await prefs.remove('jwt');

    // Show a snackbar or navigate after logout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
    // Optionally, navigate to the login page
    context.go('/login'); // Adjust the route as necessary
  }

  static Future<bool> isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('role');
    return userRole == 'admin';
  }
}
