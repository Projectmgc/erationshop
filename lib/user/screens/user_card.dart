import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ration Cards',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      //home: const UserCard(),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rationCards = [
      {
        'name': 'John Doe',
        'cardNumber': '**** **** 1234',
        'familyMembers': [
          {'name': 'John Doe', 'id': 'ID123', 'aadhaar': '1234-5678-9012', 'removed': false},
          {'name': 'Jane Doe', 'id': 'ID124', 'aadhaar': '1234-5678-9013', 'removed': false},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ration Cards'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
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
  void _navigateToMemberRemovalPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberRemovalPage(
          card: widget.card,
          memberIndex: index,
        ),
      ),
    );
  }

  void _navigateToAddMemberPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMemberPage(card: widget.card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      icon: Icon(
                        Icons.delete,
                        color: member['removed'] ? Colors.grey : Colors.red,
                      ),
                      onPressed: member['removed']
                          ? null
                          : () => _navigateToMemberRemovalPage(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _navigateToAddMemberPage,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberRemovalPage extends StatefulWidget {
  final Map<String, dynamic> card;
  final int memberIndex;

  const MemberRemovalPage({required this.card, required this.memberIndex, super.key});

  @override
  _MemberRemovalPageState createState() => _MemberRemovalPageState();
}

class _MemberRemovalPageState extends State<MemberRemovalPage> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  FilePickerResult? _consentFile;

  void _pickConsentFile() async {
    final consentFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (consentFile != null) {
      setState(() {
        _consentFile = consentFile;
      });
    }
  }

  void _verifyAndSubmitDeletion() {
    if (_reasonController.text.isEmpty || _consentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required details.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('OTP Verification'),
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
                    widget.card['familyMembers'][widget.memberIndex]['removed'] = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member removed successfully!')),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
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
        title: const Text('Remove Member'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason for Removal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickConsentFile,
              child: Text(_consentFile == null ? 'Attach Consent File' : 'Change Consent File'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _verifyAndSubmitDeletion,
              child: const Text('Submit Deletion'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}

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
  final TextEditingController _otpController = TextEditingController();
  FilePickerResult? _aadhaarFile;

  void _pickAadhaarFile() async {
    final file = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
    if (file != null) {
      setState(() {
        _aadhaarFile = file;
      });
    }
  }

  void _verifyAndSubmit() {
    if (_nameController.text.isEmpty ||
        _aadhaarController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _aadhaarFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required details.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('OTP Verification'),
          content: TextField(
            controller: _otpController,
            decoration: const InputDecoration(labelText: 'Enter OTP'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_otpController.text == '123456') {
                  widget.card['familyMembers'].add({
                    'name': _nameController.text,
                    'id': 'ID${DateTime.now().millisecondsSinceEpoch}',
                    'aadhaar': _aadhaarController.text,
                    'removed': false,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member added successfully!')),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
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
        title: const Text('Add Member'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Member Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _aadhaarController,
              decoration: const InputDecoration(labelText: 'Aadhaar Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAadhaarFile,
              child: Text(_aadhaarFile == null ? 'Attach Aadhaar File' : 'Change Aadhaar File'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _verifyAndSubmit,
              child: const Text('Add Member'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 201, 155, 4)
        ),
      );
  }
}
