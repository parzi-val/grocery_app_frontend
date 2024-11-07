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

  Future<void> createOrder(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/orders/checkout'),
      headers: {
        'Authorization':
            'Bearer ${await Auth.getUser()}', // Replace with actual JWT token
      },
    );

    if (response.statusCode == 201) {
      final orderData = json.decode(response.body);
      final orderId = orderData['orderId'];
      context.go('/order/$orderId');
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order')),
      );
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
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                "Cart is empty",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final product = item['product'];
                final quantity = item['quantity'];

                return Card(
                  elevation: 3.0,
                  margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 6.0),
                              Text(
                                "Price: \$${product['price']}",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey[700]),
                              onPressed: () {
                                removeItem(product['_id']);
                              },
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                  onPressed: () {
                                    if (quantity > 1) {
                                      updateQuantity(product['_id'], -1);
                                    }
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  color: Colors.green,
                                  onPressed: () {
                                    updateQuantity(product['_id'], 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Add a Checkout button in bottomNavigationBar
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  createOrder(context); // Navigate to the checkout page
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Proceed to Checkout"),
              ),
            )
          : null,
    );
  }
}
