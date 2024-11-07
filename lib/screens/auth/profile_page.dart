import 'package:flutter/material.dart';
import 'package:grocery_frontend/utils/log_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:grocery_frontend/utils/auth.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userInfo;
  List<dynamic> orderHistory = [];
  bool isLoading = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _pnoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    fetchOrderHistory();
  }

  Future<void> _fetchUserInfo() async {
    String? token = await Auth.getUser();

    if (token != null) {
      final userResponse = await http.get(
        Uri.parse('http://localhost:5000/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userResponse.statusCode == 200) {
        setState(() {
          userInfo = json.decode(userResponse.body)['user'];
          isLoading = false;
        });

        _nameController.text = userInfo?['name'] ?? '';
        _emailController.text = userInfo?['email'] ?? '';
        _streetController.text = userInfo?['address']?['street'] ?? '';
        _cityController.text = userInfo?['address']?['city'] ?? '';
        _stateController.text = userInfo?['address']?['state'] ?? '';
        _postalCodeController.text = userInfo?['address']?['postalCode'] ?? '';
        _countryController.text = userInfo?['address']?['country'] ?? '';
        _pnoController.text = userInfo?['phoneNumber'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data.')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchOrderHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/orders/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Auth.getUser()}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orderHistory = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      LogService.e('Error fetching order history: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showEditModal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 400,
            child: AlertDialog(
              title: Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _pnoController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _streetController,
                        decoration: InputDecoration(labelText: 'Street'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(labelText: 'City'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _stateController,
                        decoration: InputDecoration(labelText: 'State'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(labelText: 'Postal Code'),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: _countryController,
                        decoration: InputDecoration(labelText: 'Country'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final name = _nameController.text;
                    final email = _emailController.text;
                    final street = _streetController.text;
                    final city = _cityController.text;
                    final state = _stateController.text;
                    final postalCode = _postalCodeController.text;
                    final country = _countryController.text;
                    final phoneNumber = _pnoController.text;

                    final Map<String, dynamic> userData = {
                      'name': name,
                      'email': email,
                      'phoneNumber': phoneNumber,
                      'address': {
                        'street': street,
                        'city': city,
                        'state': state,
                        'postalCode': postalCode,
                        'country': country,
                      }
                    };

                    try {
                      final response = await http.put(
                        Uri.parse('http://localhost:5000/api/auth/profile'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                        body: json.encode(userData),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Profile updated successfully!')),
                        );
                        context.go('/profile');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update profile!')),
                        );
                      }
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An error occurred: $error')),
                      );
                    }
                  },
                  child: Text('Save Changes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'Profile',
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Auth.logout(context);
                context.push('/');
              }),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Information Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: _showEditModal,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (userInfo != null) ...[
                            Text('Name: ${userInfo!['name']}'),
                            SizedBox(height: 5),
                            Text('Email: ${userInfo!['email']}'),
                            SizedBox(height: 5),
                            Text(
                                'Phone Number: ${userInfo!['phoneNumber']?.isNotEmpty == true ? userInfo!['phoneNumber'] : 'not set'}'),
                            SizedBox(height: 10),
                            Text('Address:'),
                            Text('${userInfo?['address']?['street'] ?? ''}'),
                            Text(
                                '${userInfo?['address']?['city'] ?? ''} ${userInfo?['address']?['state'] ?? ''} ${userInfo?['address']?['postalCode'] ?? ''}'),
                            Text(
                                '${userInfo?['address']?['country'] ?? 'not available'}'),
                          ] else
                            Text('User information not available.'),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  // Order History Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order History",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        if (orderHistory.isNotEmpty) ...[
                          ListView.builder(
                            shrinkWrap:
                                true, // To prevent ListView from taking too much space in Column
                            physics:
                                NeverScrollableScrollPhysics(), // Disable scrolling for the ListView itself
                            itemCount: orderHistory.length,
                            itemBuilder: (context, index) {
                              final order = orderHistory[index];
                              return InkWell(
                                onTap: () {
                                  context.go('/order/${order['orderId']}');
                                },
                                child: Card(
                                  margin: EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Order #${order['orderId']}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Text("Status: ${order['status']}"),
                                        Text(
                                            "Total Amount: \$${order['totalAmount']}"),
                                        Text(
                                            "Order Date: ${order['createdAt']}"),
                                        Divider(),
                                        Text("Items:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        ...order['items'].map<Widget>((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "${item['product']} x${item['quantity']}"),
                                                Text("\$${item['total']}"),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ] else
                          Text("No order history available."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
