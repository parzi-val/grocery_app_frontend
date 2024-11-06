import 'package:flutter/material.dart';
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:grocery_frontend/utils/log_service.dart';
import 'dart:convert';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<Map<String, dynamic>?> getCart() async {
    final url = Uri.parse('http://localhost:5000/api/cart');

    final headers = {
      'Authorization': 'Bearer ${await Auth.getUser()}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        LogService.w('Failed to fetch cart: ${response.body}');
      }
    } catch (e) {
      LogService.e('Error fetching cart: $e');
    }
    return null;
  }

  Future<void> removeFromCart(String productId) async {
    final url = Uri.parse('http://localhost:5000/api/cart/$productId');

    final headers = {
      'Authorization': 'Bearer ${await Auth.getUser()}',
    };

    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        LogService.i('Product removed from cart');
      } else {
        LogService.w('Failed to remove product: ${response.body}');
      }
    } catch (e) {
      LogService.e('Error removing product: $e');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    final userId = await Auth.getUser();
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

  Future<void> fetchCart() async {
    final cartData = await getCart();
    if (cartData != null) {
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(cartData['items']);
      });
    }
  }

  Future<void> updateQuantity(String productId, int delta) async {
    await addToCart(productId, delta);
    fetchCart(); // Refresh cart after updating
  }

  Future<void> removeItem(String productId) async {
    await removeFromCart(productId);
    fetchCart(); // Refresh cart after removing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
          title: "Your Cart",
          actions: [],
          leading: IconButton(
              onPressed: () => {context.pop()}, icon: Icon(Icons.arrow_back))),
      body: cartItems.isEmpty
          ? Center(child: Text("Cart is empty"))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final product = item['product'];
                final quantity = item['quantity'];

                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text("Price: \$${product['price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            updateQuantity(product['_id'], -1);
                          }
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          updateQuantity(product['_id'], 1);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeItem(product['_id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
