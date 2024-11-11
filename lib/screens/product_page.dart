import 'package:flutter/material.dart';
import 'package:grocery_frontend/widgets/header.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:grocery_frontend/widgets/user_product_card.dart';
import 'package:grocery_frontend/utils/auth.dart';
import 'package:grocery_frontend/utils/log_service.dart';
import 'package:grocery_frontend/globals.dart' as globals;
import 'dart:convert';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  ProductPageState createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage> {
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
    _fetchAllProducts();
    _fetchCategories();
    // globals.headerKey.currentState?.refresh();
  }

  Future<void> _fetchAllProducts() async {
    final response = await http.get(Uri.parse('${globals.url}/api/products/'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${globals.url}/api/products/categories/'),
        headers: {
          'Authorization': 'Bearer ${await Auth.getUser()}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> categoryList = json.decode(response.body);

        setState(() {
          categories = List<String>.from(categoryList);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      LogService.e('Error fetching categories: $error');
    }
  }

  Future<void> _fetchProducts(
      {String? name,
      List<dynamic>? categories,
      double? minPrice,
      double? maxPrice}) async {
    List<String>? categories =
        selectedCategories?.map((e) => e.toString()).toList();
    StringBuffer query = StringBuffer('${globals.url}/api/products/search?');

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
    setState(() {
      searchQuery = '';
      selectedCategories = [];
      minPrice = null;
      maxPrice = null;
    });

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
    await _fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4;

    return Scaffold(
      appBar: Header(
        title: 'Products',
        actions: [],
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
                    onSubmitted: (value) {
                      _fetchProducts(
                          name: value); // This will trigger on Enter key press
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Products',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _fetchProducts(
                              name:
                                  searchQuery); // This will trigger on search icon press
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterDialog();
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
                  controller: minPriceController,
                  decoration: InputDecoration(labelText: 'Min Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    minPrice = double.tryParse(value);
                  },
                ),
                TextField(
                  controller: maxPriceController,
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
                  selectedCategories =
                      multiDropDownKey.currentState?.getSelectedItems;
                });
                Navigator.of(context).pop();
                _fetchProducts(
                    categories: selectedCategories,
                    minPrice: double.tryParse(minPriceController.text),
                    maxPrice: double.tryParse(maxPriceController.text));
              },
              child: Text('Apply Filters'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategories = [];
                  minPrice = null;
                  maxPrice = null;
                  minPriceController.clear();
                  maxPriceController.clear();

                  multiDropDownKey.currentState?.clear();
                });
                Navigator.of(context).pop();
                refresh();
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
