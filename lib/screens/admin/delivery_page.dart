import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_frontend/utils/auth.dart'; // Ensure you have the Auth class for token handling
import 'package:grocery_frontend/utils/log_service.dart'; // Ensure you have a log service for logging
import 'package:grocery_frontend/globals.dart' as globals;

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  DeliveryPageState createState() => DeliveryPageState();
}

class DeliveryPageState extends State<DeliveryPage> {
  List<dynamic> orders = [];
  List<dynamic> deliveryPartners = [];
  String apiUrl = "${globals.url}/api/orders"; // Your API URL

  @override
  void initState() {
    super.initState();
    fetchOrders();
    fetchDeliveryPartners();
  }

  // Fetch Orders from the API
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

  // Fetch Delivery Partners from the API
  Future<void> fetchDeliveryPartners() async {
    try {
      final token = await Auth.getUser();
      final response = await http.get(
        Uri.parse(
            "${globals.url}/api/delivery/delivery-partners"), // Your API for delivery partners
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          deliveryPartners = json.decode(response.body);
        });
      } else {
        LogService.w('Failed to load delivery partners');
      }
    } catch (e) {
      LogService.e('Error: $e');
    }
  }

  // Assign a Delivery Partner to an Order
  Future<void> assignDeliveryPartner(
      String orderId, String deliveryPartnerId) async {
    try {
      final token = await Auth.getUser();
      final response = await http.post(
        Uri.parse("${globals.url}/api/delivery/assign-delivery-partner"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'orderId': orderId,
          'deliveryPersonId': deliveryPartnerId,
        }),
      );
      if (response.statusCode == 201) {
        LogService.i('Delivery Partner Assigned');
        fetchOrders(); // Re-fetch the orders to update the table
      } else {
        LogService.w('Failed to assign delivery partner');
      }
    } catch (e) {
      LogService.e('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the whole body
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4, // Card shadow for better UI
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orders List',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold), // Title in bold
                      ),
                      SizedBox(height: 16), // Space between title and table
                      DataTable(
                        columns: [
                          DataColumn(label: Text('Order ID')),
                          DataColumn(label: Text('Customer Name')),
                          DataColumn(label: Text('Total Amount')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Assign Delivery Partner')),
                        ],
                        rows: orders.map((order) {
                          return DataRow(cells: [
                            DataCell(Text(order['_id'])),
                            DataCell(Text(order['user']['name'])),
                            DataCell(Text("\$${order['totalAmount']}")),
                            DataCell(Text(order['status'])),
                            DataCell(
                              DropdownButton<String>(
                                value: order['deliveryPersonnel'],
                                hint: Text('Assign'),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    assignDeliveryPartner(order['_id'], value);
                                  }
                                },
                                items: deliveryPartners
                                    .map<DropdownMenuItem<String>>((partner) {
                                  return DropdownMenuItem<String>(
                                    value: partner['_id'],
                                    child: Text(partner['name']),
                                  );
                                }).toList(),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
