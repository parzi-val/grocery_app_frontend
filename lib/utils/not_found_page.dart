import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404 - Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Oops! The page you are looking for does not exist.',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () {
                // Navigate to the home page using GoRouter
                context.go(
                    '/'); // Assuming your home page is set at the root route
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
