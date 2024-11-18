import 'package:flutter/material.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for multiple users' ration cards
    final List<Map<String, dynamic>> rationCards = [
      {
        'name': 'John Doe',
        'cardNumber': '**** **** 1234',
        'familyMembers': [
          {'name': 'John Doe', 'id': 'ID123'},
          {'name': 'Jane Doe', 'id': 'ID124'},
        ],
      },
      {
        'name': 'Jane Smith',
        'cardNumber': '**** **** 5678',
        'familyMembers': [
          {'name': 'Jane Smith', 'id': 'ID125'},
          {'name': 'Emily Smith', 'id': 'ID126'},
        ],
      },
      {
        'name': 'Robert Brown',
        'cardNumber': '**** **** 9101',
        'familyMembers': [
          {'name': 'Robert Brown', 'id': 'ID127'},
          {'name': 'Sarah Brown', 'id': 'ID128'},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ration Cards'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: rationCards.length,
        itemBuilder: (context, index) {
          final card = rationCards[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.deepPurpleAccent),
              title: Text(card['name']),
              subtitle: Text('Card Number: ${card['cardNumber']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailsPage(card: card),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CardDetailsPage extends StatelessWidget {
  final Map<String, dynamic> card;

  const CardDetailsPage({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurpleAccent,
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.white, size: 30),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add or change profile picture.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cardholder: ${card['name']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Card Number: ${card['cardNumber']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Family Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: (card['familyMembers'] as List).length,
                itemBuilder: (context, index) {
                  final member = card['familyMembers'][index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurpleAccent,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(member['name']),
                    subtitle: Text('ID: ${member['id']}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Manage ${card['name']}\`s Card')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Manage Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
