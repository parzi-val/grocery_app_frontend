import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grocery_frontend/widgets/header.dart';

class IndiProductPage extends StatelessWidget {
  const IndiProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String productId = arguments['id'];

    Future<Map<String, dynamic>> fetchProductDetails(String id) async {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/products/$id'));

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
                              onPressed: () {},
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
