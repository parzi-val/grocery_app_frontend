import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/globals.dart' as globals;
import 'dart:convert';

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
                    'Authorization': 'Bearer ${await Auth.getUser()}',
                  },
                  body: json.encode({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'price': priceController.text,
                    'stock': stockController.text
                  }),
                );
                Navigator.of(context).pop();
                globals.adminProductPageKey.currentState?.refresh();
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
                    headers: {
                      'Authorization': 'Bearer ${await Auth.getUser()}'
                    });
                Navigator.of(context).pop();
                _fetchProducts(); // Refresh the product list
                globals.adminProductPageKey.currentState?.refresh();
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product; // Access the product

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showEditDialog(
                    product['_id'],
                    product['name'],
                    product['description'],
                    "${product['price']}",
                    "${product['stock']}",
                  ),
                  child: Text('Edit', style: TextStyle(fontSize: 12)),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmDelete(product['_id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
