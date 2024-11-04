import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:grocery_frontend/widgets/product_card.dart';
import 'package:grocery_frontend/utils/auth.dart';

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  AdminProductPageState createState() => AdminProductPageState();
}

class AdminProductPageState extends State<AdminProductPage> {
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final multiDropDownKey = GlobalKey<DropdownSearchState>();
  List<dynamic> products = [];
  List<String> categories = [];
  String searchQuery = '';
  double? minPrice;
  double? maxPrice;
  List<dynamic>? selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Initial fetch of products
    _fetchCategories(); // Fetch categories for dropdown
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/api/products/categories/'), // Replace with your API URL
        headers: {
          'Authorization':
              'Bearer ${await Auth.getUser()}', // Include token if required
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

  Future<void> _fetchProducts(
      {String? name,
      List<dynamic>? categories,
      double? minPrice,
      double? maxPrice}) async {
    List<String>? categories =
        selectedCategories?.map((e) => e.toString()).toList();
    StringBuffer query = StringBuffer('http://localhost:5000/api/products?');

    if (name != null && name.isNotEmpty) {
      query.write('name=$name&');
    }
    if (categories != null && categories.isNotEmpty) {
      query.write('category=${categories.join(",")}&');
    }
    if (minPrice != null) {
      query.write('minPrice=$minPrice&');
    }
    if (maxPrice != null) {
      query.write('maxPrice=$maxPrice&');
    }

    final response = await http.get(Uri.parse(query.toString()));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> refresh() async {
    await _fetchProducts(
        name: searchQuery,
        categories: selectedCategories,
        minPrice: minPrice,
        maxPrice: maxPrice);
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final stockController = TextEditingController();

    // Temporary list of categories (this should come from your backend)
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
                    'Authorization': 'Bearer ${Auth.getUser()}',
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
    final itemWidth = screenWidth / 4;

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 30),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Products',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          refresh(); // Call refresh to fetch products based on the search query
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterDialog(); // Show filter dialog
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: itemWidth / 250,
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                final shortenedDescription = product['description'].length > 50
                    ? product['description'].substring(0, 50) + '...'
                    : product['description'];

                return ProductCard(
                  product: product,
                  shortenedDescription: shortenedDescription,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Create text controllers for the price fields
    final minPriceController = TextEditingController(
        text: minPrice != null ? minPrice.toString() : '');
    final maxPriceController = TextEditingController(
        text: maxPrice != null ? maxPrice.toString() : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Products'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                DropdownSearch<String>.multiSelection(
                  key: multiDropDownKey,
                  items: categories,
                  selectedItems:
                      selectedCategories?.map((e) => e.toString()).toList() ??
                          [],
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Category...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupPropsMultiSelection.menu(
                    showSelectedItems: true,
                    showSearchBox: true,
                  ),
                ),
                TextField(
                  controller: minPriceController, // Use the controller here
                  decoration: InputDecoration(labelText: 'Min Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    minPrice = double.tryParse(value);
                  },
                ),
                TextField(
                  controller: maxPriceController, // Use the controller here
                  decoration: InputDecoration(labelText: 'Max Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    maxPrice = double.tryParse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Get selected categories and apply filters
                  selectedCategories =
                      multiDropDownKey.currentState?.getSelectedItems;
                });
                Navigator.of(context).pop();
                refresh(); // Refresh products with the selected filters
              },
              child: Text('Apply Filters'),
            ),
            TextButton(
              onPressed: () {
                // Clear the filters
                setState(() {
                  selectedCategories = []; // Clear selected categories
                  minPrice = null; // Clear min price
                  maxPrice = null; // Clear max price
                  minPriceController.clear(); // Clear the text field
                  maxPriceController.clear(); // Clear the text field
                  // Reset the dropdown selection in the filter dialog
                  multiDropDownKey.currentState?.clear();
                });
                Navigator.of(context).pop();
                refresh(); // Refresh products without filters
              },
              child: Text('Clear Filters'),
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
}
