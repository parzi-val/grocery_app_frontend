import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_frontend/utils/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:grocery_frontend/utils/log_service.dart';
import 'dart:convert';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({required this.orderId, super.key});

  @override
  OrderDetailsPageState createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/orders/${widget.orderId}'),
      headers: {
        'Authorization':
            'Bearer ${await Auth.getUser()}', // Replace with actual JWT token
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        orderData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order details')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (orderData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Order Details')),
        body: Center(child: Text('Failed to load order details')),
      );
    }

    final items = orderData!['items'] as List<dynamic>;

    return Scaffold(
      appBar: Header(
        title: 'Order #${orderData!['orderId']}',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column for order items
                  Expanded(
                    flex: 3, // Takes more space
                    child: SingleChildScrollView(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.grey[50],
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Items',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),
                              ...items.map((item) {
                                return ListTile(
                                  title: Text(item['product']),
                                  subtitle:
                                      Text('Quantity: ${item['quantity']}'),
                                  trailing: Text('\$${item['total']}'),
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16.0),

                  // Right column for order summary and user details
                  Expanded(
                    flex: 2, // Takes less space
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.grey[50],
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('User: ${orderData!['user']['name']}'),
                              Text('Email: ${orderData!['user']['email']}'),
                              Text(
                                  'Phone: ${orderData!['user']['phoneNumber']}'),
                              SizedBox(height: 10),
                              Text('Address:'),
                              Text(
                                  '${orderData!['user']['address']?['street'] ?? ''}'),
                              Text(
                                  '${orderData!['user']['address']?['city'] ?? ''} ${orderData!['user']['address']?['state'] ?? ''} ${orderData!['user']['address']?['postalCode'] ?? ''}'),
                              Text(
                                  '${orderData!['user']['address']?['country'] ?? 'not available'}'),
                              Divider(),
                              Text(
                                'Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                  'Total Amount: \$${orderData!['totalAmount']}'),
                              Text('Status: ${orderData!['status']}'),
                              Text(
                                'Estimated Delivery: ${orderData!['estimatedDelivery']}',
                              ),
                              SizedBox(height: 40),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (orderData != null &&
                                        orderData!['orderId'] != null) {
                                      // Navigate to the payment page with the order ID
                                      context.go(
                                          '/payment/${orderData!['orderId']}');
                                    } else {
                                      LogService.e('Order ID is missing');
                                    }
                                  },
                                  child: (orderData != null &&
                                          orderData!['status'] ==
                                              'Pending Payment')
                                      ? Text('Proceed to Payment')
                                      : SizedBox(
                                          width:
                                              10), // Placeholder widget when the button should not be shown
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Proceed to Payment button
          ],
        ),
      ),
    );
  }
}
