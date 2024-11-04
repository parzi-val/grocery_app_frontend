import 'package:flutter/material.dart';
import 'package:grocery_frontend/widgets/header.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'Grocery App',
        actions: [],
      ),
      body: Center(
        child: Text('Product list will be displayed here.'),
      ),
    );
  }
}
