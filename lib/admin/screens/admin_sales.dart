import 'package:flutter/material.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: Center(child: const Text('Sales Page Content')),
    );
  }
}
