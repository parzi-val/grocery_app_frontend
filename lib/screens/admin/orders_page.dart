import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/globals.dart' as globals;
import 'package:grocery_frontend/utils/log_service.dart';
import 'dart:convert';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  OrdersPageState createState() => OrdersPageState();
}

class OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  List<String> statuses = [
    'Shipped',
    'Delivered',
    'Cancelled',
    'Pending Payment',
    'Confirmed'
  ];
  String selectedStatus = '';
  final String apiUrl = '${globals.url}/api/orders';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // Fetch all orders from the API with auth header
  Future<void> fetchOrders() async {
    try {
      final token = await Auth.getUser();
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
        });
      } else {
        LogService.w('Failed to load orders');
      }
    } catch (e) {
      LogService.e('Error: $e');
    }
  }

  // Update order status with auth header
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final token = await Auth.getUser();
      final response = await http.put(
        Uri.parse('$apiUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        LogService.i('Order updated successfully');
        fetchOrders(); // Refresh orders after updating
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderId updated to $newStatus'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        LogService.w('Failed to update order');
      }
    } catch (e) {
      LogService.i('Error: $e');
    }
  }

  // Delete an order with auth header
  Future<void> deleteOrder(String orderId) async {
    try {
      final token = await Auth.getUser();
      final response = await http.delete(
        Uri.parse('$apiUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        LogService.i('Order deleted successfully');
        fetchOrders(); // Refresh orders after deleting
      } else {
        LogService.w('Failed to delete order');
      }
    } catch (e) {
      LogService.e('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Orders')),
      body: orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                selectedStatus = order['status'];

                // Determine if buttons should be disabled based on status
                bool isShipped = selectedStatus == 'Shipped';
                bool isDelivered = selectedStatus == 'Delivered';
                bool isCancelled = selectedStatus == 'Cancelled';

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order['_id']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Total Amount: \$${order['totalAmount']}'),
                        Text('Status: $selectedStatus'),
                        SizedBox(height: 10),
                        // 3 Buttons for Shipped, Delivered, Cancelled
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: isShipped
                                  ? null // Disable button if status is 'Shipped'
                                  : () {
                                      setState(() {
                                        selectedStatus =
                                            'Shipped'; // Set status to Shipped
                                      });
                                      updateOrderStatus(order['_id'],
                                          selectedStatus); // Call update function
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isShipped
                                    ? Colors.grey
                                    : null, // Gray out if shipped
                              ),
                              child: Text('Shipped'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: isDelivered
                                  ? null // Disable all buttons if status is 'Delivered'
                                  : () {
                                      setState(() {
                                        selectedStatus =
                                            'Delivered'; // Set status to Delivered
                                      });
                                      updateOrderStatus(order['_id'],
                                          selectedStatus); // Call update function
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDelivered
                                    ? Colors.grey
                                    : null, // Gray out if delivered
                              ),
                              child: Text('Delivered'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: isCancelled
                                  ? null // Disable button if status is 'Cancelled'
                                  : () {
                                      setState(() {
                                        selectedStatus =
                                            'Cancelled'; // Set status to Cancelled
                                      });
                                      updateOrderStatus(order['_id'],
                                          selectedStatus); // Call update function
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCancelled
                                    ? Colors.grey
                                    : null, // Gray out if cancelled
                              ),
                              child: Text('Cancelled'),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => deleteOrder(order['_id']),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
