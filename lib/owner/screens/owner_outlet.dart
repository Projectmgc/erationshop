import 'package:flutter/material.dart';

class OutletPage extends StatelessWidget {
  const OutletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Outlet")),
      body: Center(child: Text("Outlet Page")),
    );
  }
}
