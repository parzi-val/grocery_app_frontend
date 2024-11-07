import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_frontend/utils/auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:grocery_frontend/utils/log_service.dart';

class ProductCard extends StatefulWidget {
  final dynamic product;
  final String shortenedDescription;

  const ProductCard(
      {super.key, required this.product, required this.shortenedDescription});

  @override
  ProductCardState createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  List<dynamic> products = [];
  @override
  void initState() {
    super.initState();
  }

  Future<void> addToCart(String productId, int quantity) async {
    final userId = await Auth.getUser();
    if (userId == null) {
      context.go('/login');
    }
    final url = Uri.parse('http://localhost:5000/api/cart/add');

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
    final product = widget.product;

    return InkWell(
      onTap: () {
        context.go('/products/${product['_id']}');
        Navigator.pushNamed(
          context,
          '/product',
          arguments: {'id': product['_id']},
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(padding: const EdgeInsets.all(8.0)),
            Image.network(
              product['imageUrl'],
              height: 125,
              width: 125,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 125);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.shortenedDescription,
                style: TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text('Add to Cart'),
                  onPressed: () => {
                    addToCart(product['_id'], 1),
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
