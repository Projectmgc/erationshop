import 'package:flutter/material.dart';



class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for multiple users' ration cards
    final List<Map<String, dynamic>> rationCards = [
      {
        'name': 'John Doe',
        'cardNumber': '**** **** 1234',
        'familyMembers': [
          {'name': 'John Doe', 'id': 'ID123', 'aadhaar': '1234-5678-9012'},
          {'name': 'Jane Doe', 'id': 'ID124', 'aadhaar': '1234-5678-9013'},
        ],
      },
      {
        'name': 'Jane Smith',
        'cardNumber': '**** **** 5678',
        'familyMembers': [
          {'name': 'Jane Smith', 'id': 'ID125', 'aadhaar': '1234-5678-9014'},
          {'name': 'Emily Smith', 'id': 'ID126', 'aadhaar': '1234-5678-9015'},
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

class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> card;

  const CardDetailsPage({required this.card, super.key});

  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  bool isVerified = false;
  final TextEditingController _otpController = TextEditingController();

  // Method to verify OTP
  void _verifyOTP(String action, int index) {
    if (_otpController.text == '123456') { // Hardcoded OTP for demonstration
      setState(() {
        isVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Verified Successfully')),
      );
      // Perform action after OTP verification
      if (action == 'add') {
        _addMember();
      } else if (action == 'delete') {
        _deleteMember(index);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  // Method to add a new member
  void _addMember() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController aadhaarController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Family Member'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: aadhaarController,
                decoration: const InputDecoration(labelText: 'Aadhaar Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.card['familyMembers'].add({
                    'name': nameController.text,
                    'id': 'ID${widget.card['familyMembers'].length + 1}',
                    'aadhaar': aadhaarController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Add Member'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a member
  void _deleteMember(int index) {
    setState(() {
      widget.card['familyMembers'].removeAt(index);
    });
  }

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
                        const SnackBar(content: Text('Add or change profile picture.')));
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cardholder: ${widget.card['name']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Card Number: ${widget.card['cardNumber']}',
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
                itemCount: (widget.card['familyMembers'] as List).length,
                itemBuilder: (context, index) {
                  final member = widget.card['familyMembers'][index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurpleAccent,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(member['name']),
                    subtitle: Text('ID: ${member['id']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _verifyOTP('delete', index); // Verify OTP before deleting
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _verifyOTP('add', 0); // Verify OTP before adding a new member
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Add Member'),
              ),
            ),
            if (!isVerified)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
