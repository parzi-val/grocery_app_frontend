import 'package:flutter/material.dart';
import 'package:grocery_frontend/utils/log_service.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:grocery_frontend/globals.dart' as globals;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final String orderId;

  const PaymentPage({super.key, required this.orderId});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<bool> confirmPayment() async {
    final url = Uri.parse(
        '${globals.url}/api/payments/confirm-payment/${widget.orderId}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${await Auth.getUser()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successfully confirmed the payment
        LogService.i('Payment confirmed successfully!');
        return true;
      } else if (response.statusCode == 404) {
        LogService.w('Order not found');
        return false;
      } else if (response.statusCode == 400) {
        LogService.i('Order is already confirmed');
        return false;
      } else {
        LogService.w('Failed to confirm payment: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      LogService.e('Error confirming payment: $error');
      return false;
    }
  }

  Future<void> fetchOrderDetails() async {
    final response = await http.get(
      Uri.parse('${globals.url}/api/orders/${widget.orderId}'),
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
    return Scaffold(
      appBar: Header(
        title: 'Checkout',
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
        child: Row(
          children: [
            // Left Side: Payment Details Form in a Card
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // VAT and PO Number Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'VAT Number',
                                hintText: 'Optional',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'PO Number',
                                hintText: 'Optional',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Payment Method Section
                      Text(
                        'Payment Method',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          _buildPaymentOptionIcon(Icons.credit_card, "Visa"),
                          _buildPaymentOptionIcon(
                              Icons.credit_card, "Mastercard"),
                          _buildPaymentOptionIcon(Icons.credit_card, "Amex"),
                          _buildPaymentOptionIcon(
                              Icons.account_balance_wallet, "PayPal"),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Card Details Fields
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Cardholder Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (value) {}),
                          Text('Save my payment details for future purchases'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 16),

            // Right Side: Order Summary Section in a Card
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      _buildSummaryRow(
                          'Total amount:', '\$${orderData!['totalAmount']}'),
                      SizedBox(height: 10),
                      _buildSummaryRow('VAT (21%):', '€ 21.00'),
                      Divider(thickness: 1),
                      SizedBox(height: 10),
                      _buildSummaryRow(
                          'Total:', '€ ${orderData!['totalAmount'] + 21}',
                          isBold: true),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          confirmPayment();
                          // Mock confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Payment Successful'),
                              content: Text(
                                  'Your payment of € ${orderData!['totalAmount'] + 21} for Order ID ${widget.orderId} has been processed.'),
                              actions: [
                                TextButton(
                                  onPressed: () => context.go('/'),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text('Confirm your order'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for payment option icons
  Widget _buildPaymentOptionIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          Text(label),
        ],
      ),
    );
  }

  // Helper method for building summary rows
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
