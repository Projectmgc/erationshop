import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// UserCard Widget
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
        'familyMembers':[
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

// Card Details Page
class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> card;

  const CardDetailsPage({required this.card, super.key});

  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final TextEditingController _otpController = TextEditingController();
  bool isOwnerChanging = false;
  XFile? _imageFile;
  FilePickerResult? _consentFile;

  // Method to add a new member
  void _navigateToAddMemberPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMemberPage(card: widget.card),
      ),
    );
  }

  // Select new owner and pick profile photo
  void _selectNewOwner(int index) async {
    final consentFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (consentFile != null) {
      setState(() {
        _consentFile = consentFile;
      });
      // Select new profile photo for owner change
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });

      // Show confirmation screen (OTP)
      _showOTPVerification();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consent letter file not selected')),
      );
    }
  }

  // OTP verification
  void _showOTPVerification() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: _otpController,
            decoration: const InputDecoration(labelText: 'Enter OTP'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_otpController.text == '123456') {
                  setState(() {
                    isOwnerChanging = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Owner changed successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid OTP')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
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
            Text(
              'Cardholder: ${widget.card['name']}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Card Number: ${widget.card['cardNumber']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              'Family Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.card['familyMembers'].length,
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
                        if (index == 0) {
                          _selectNewOwner(index); // Owner removal logic
                        } else {
                          // Regular member removal
                          setState(() {
                            widget.card['familyMembers'].removeAt(index);
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToAddMemberPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Add Member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Member Page
class AddMemberPage extends StatefulWidget {
  final Map<String, dynamic> card;

  const AddMemberPage({required this.card, super.key});

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Validate and add member
  void _addMember() {
    if (_nameController.text.isEmpty ||
        _aadhaarController.text.isEmpty ||
        _ageController.text.isEmpty ||
        !_isValidAadhaar(_aadhaarController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid data')),
      );
      return;
    }

    setState(() {
      widget.card['familyMembers'].add({
        'name': _nameController.text,
        'id': 'ID${widget.card['familyMembers'].length + 1}',
        'aadhaar': _aadhaarController.text,
      });
    });
    Navigator.pop(context);
  }

  bool _isValidAadhaar(String aadhaar) {
    return aadhaar.length == 12 && RegExp(r'^[0-9]+$').hasMatch(aadhaar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _aadhaarController,
              decoration: const InputDecoration(labelText: 'Aadhaar Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const UserCard(),
    debugShowCheckedModeBanner: false,
  ));
}
