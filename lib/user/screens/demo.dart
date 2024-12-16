import 'package:flutter/material.dart';

void main() {
  runApp(CardDetailsApp());
}

class CardDetailsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardDetailsPage(),
    );
  }
}

class CardDetailsPage extends StatelessWidget {
  final List<Map<String, String>> familyMembers = [
    {"name": "John Doe", "id": "ID123"},
    {"name": "Jane Doe", "id": "ID124"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        title: Text("Card Details"),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cardholder Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Cardholder: John Doe",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8),
            child: Text(
              "Card Number: ** ** 1234",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          // Family Members Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Family Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: familyMembers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(familyMembers[index]["name"]!),
                    subtitle: Text("ID: ${familyMembers[index]["id"]}"),
                    trailing: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}