import 'package:flutter/material.dart';

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      body: Center(child: const Text('Complaints Page Content')),
    );
  }
}
