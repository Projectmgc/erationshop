import 'package:flutter/material.dart';
import 'owner_purchase.dart'; // Import the PurchasePage

class StoreOwnerPage extends StatefulWidget {
  const StoreOwnerPage({super.key});

  @override
  _StoreOwnerPageState createState() => _StoreOwnerPageState();
}

class _StoreOwnerPageState extends State<StoreOwnerPage> {
  final _userIdController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Store Owner - User Information"),
        backgroundColor: const Color.fromARGB(255, 199, 158, 23),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User ID Input Field
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: "Enter User ID",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Username Input Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Enter Username",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            // Purchase Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Retrieve entered details
                  String userId = _userIdController.text.trim();
                  String username = _usernameController.text.trim();

                  // Check if both fields are not empty
                  if (userId.isNotEmpty && username.isNotEmpty) {
                    // Navigate to PurchasePage and pass userId and username
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchasePage(
                          userId: userId,
                          username: username,
                        ),
                      ),
                    );
                  } else {
                    // Show error if fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please enter both User ID and Username"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text("Proceed to Purchase"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 199, 168, 32),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
