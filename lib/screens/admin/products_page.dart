import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  AdminProductPageState createState() => AdminProductPageState();
}

class AdminProductPageState extends State<AdminProductPage> {
  final dropDownKey = GlobalKey<DropdownSearchState>();
  List<dynamic> products = [];
  List<String> categories = [];

  dynamic token;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _getUser();
    _fetchCategories();
  }

  Future<void> _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('jwt');
    setState(() {
      token = userToken;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/api/categories/'), // Replace with your API URL
        headers: {
          'Authorization': 'Bearer $token', // Include token if required
        },
      );

      if (response.statusCode == 200) {
        // Assuming the response body is a JSON array of category names
        List<dynamic> categoryList = json.decode(response.body);

        setState(() {
          categories = List<String>.from(categoryList);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error fetching categories: $error');
      // Optionally, show an error message to the user or handle it appropriately
    }
  }

  // Fetch product data from the API
  Future<void> _fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/api/products/'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Method to show edit product dialog
  void _showEditDialog(
      String id, String name, String description, String price, String stock) {
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: description);
    final priceController = TextEditingController(text: price);
    final stockController = TextEditingController(text: stock);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name')),
              TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description')),
              TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price')),
              TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: 'Stock')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Call the PUT request to update the product
                await http.put(
                  Uri.parse('http://localhost:5000/api/products/$id'),
                  headers: {
                    "Content-Type": "application/json",
                    'Authorization': 'Bearer $token',
                  },
                  body: json.encode({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'price': priceController.text,
                    'stock': stockController.text
                  }),
                );
                Navigator.of(context).pop();
                _fetchProducts(); // Refresh the product list
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to confirm deletion
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Call the DELETE request
                await http.delete(
                    Uri.parse('http://localhost:5000/api/products/?id=$id'),
                    headers: {'Authorization': 'Bearer $token'});
                Navigator.of(context).pop();
                _fetchProducts(); // Refresh the product list
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final stockController = TextEditingController();

    // Temporary list of categories (this should come from your backend)
    List<String> categories = [
      'Electronics',
      'Books',
      'Groceries',
      'Clothing',
      'example2',
      'example3',
      'Electronics',
      'Books',
      'Groceries',
      'Clothing',
      'example2',
      'example3'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SizedBox(
              height: 350,
              width: 800,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                  TextField(
                    controller: stockController,
                    decoration: InputDecoration(labelText: 'Stock'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  // Category dropdown with search and add functionality
                  DropdownSearch<String>(
                    key: dropDownKey,
                    items: categories,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Category...',
                      border: OutlineInputBorder(),
                    )),
                    popupProps: PopupProps.dialog(
                        showSearchBox: true,
                        title: Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(74, 98, 138, 1)),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Categories',
                                style: TextStyle(
                                  color: Colors.white,
                                ))),
                        dialogProps: DialogProps(
                            clipBehavior: Clip.antiAlias,
                            shape: OutlineInputBorder(
                                borderSide: BorderSide(width: 0),
                                borderRadius: BorderRadius.circular(25)))),
                  ),
                ],
              )),
          actions: [
            TextButton(
              onPressed: () async {
                await http.post(
                  Uri.parse('http://localhost:5000/api/products/'),
                  headers: {
                    "Content-Type": "application/json",
                    'Authorization': 'Bearer $token',
                  },
                  body: json.encode({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'price': double.tryParse(priceController.text),
                    'imageUrl': imageUrlController.text,
                    'category': dropDownKey
                        .currentState?.getSelectedItem, // Set selected category
                  }),
                );
                Navigator.of(context).pop();
                _fetchProducts(); // Refresh the product list
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4; // Dividing the screen width by 4

    return Scaffold(
        appBar: AppBar(
          title: Text('Admin Product Page'),
          actions: [
            IconButton(
              icon: Icon(Icons.add, size: 30),
              onPressed: _showAddDialog,
            ),
          ],
        ),
        body: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 items in a row
              childAspectRatio:
                  itemWidth / 250, // Adjust for height-to-width ratio
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final product = products[index];
              final shortenedDescription = product['description'].length > 50
                  ? product['description'].substring(0, 50) + '...'
                  : product['description'];

              return InkWell(
                  onTap: () {
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
                          width: 125, // Make the image width dynamic
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
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            shortenedDescription,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showEditDialog(
                                  product['_id'],
                                  product['name'],
                                  product['description'],
                                  "${product['price']}",
                                  "${product['stock']}"),
                              child:
                                  Text('Edit', style: TextStyle(fontSize: 12)),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _confirmDelete(product['_id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            }));
  }
}
