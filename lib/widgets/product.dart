import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/utils/log_service.dart';
import 'package:grocery_frontend/globals.dart' as globals;

class IndiProductPage extends StatelessWidget {
  final String productId;
  const IndiProductPage({required this.productId, super.key});

  Future<void> addToCart(BuildContext context, productId, int quantity) async {
    final userId = await Auth.getUser();
    if (userId == null) {
      context.go('/login');
    }
    final url = Uri.parse('${globals.url}/api/cart/add');

    final body = jsonEncode({
      'productId': productId,
      'userId': userId,
      'quantity': quantity,
    });
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await Auth.getUser()}',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        LogService.i('Cart updated successfully');
      } else {
        LogService.w('Failed to update cart: ${response.body}');
      }
    } catch (e) {
      LogService.e('Error updating cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> fetchProductDetails(String id) async {
      final response =
          await http.get(Uri.parse('${globals.url}/api/products/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load product details');
      }
    }

    return Scaffold(
      appBar: Header(title: "Product", actions: [], leading: null),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProductDetails(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No data found"));
          } else {
            final product = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: Image.network(
                          product['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Product Name',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Category: ${product['category'] ?? 'N/A'}",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Price: \$${product['price']?.toStringAsFixed(2) ?? '0.00'}",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.green),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "In Stock: ${product['stock'] ?? 0}",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 20),
                            SizedBox(height: 20),
                            Text(
                              "Description",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              product['description'] ??
                                  'No description available',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                addToCart(context, productId, 1);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                              child: Text("Add to Cart"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
