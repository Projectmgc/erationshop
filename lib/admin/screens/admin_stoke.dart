import 'package:flutter/material.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: Center(child: const Text('Stock Page Content')),
    );
  }
}
