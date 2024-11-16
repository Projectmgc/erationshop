import 'package:flutter/material.dart';

class ConversePage extends StatelessWidget {
  const ConversePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Converse')),
      body: Center(child: const Text('Converse Page Content')),
    );
  }
}
