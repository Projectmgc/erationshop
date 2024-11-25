import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Enquiry & Complaints',
      theme: ThemeData(),
      initialRoute: '/',
      home: UserEnquiry(),
    );
  }
}

class UserEnquiry extends StatefulWidget {
  @override
  _UserEnquiryState createState() => _UserEnquiryState();
}

class _UserEnquiryState extends State<UserEnquiry> {
  final TextEditingController _enquiryController = TextEditingController();
  List<Map<String, String>> _enquiries = [];

  // Method to handle submission of enquiries or complaints
  void _submitEnquiry() {
    String enquiryText = _enquiryController.text.trim();
    if (enquiryText.isNotEmpty) {
      setState(() {
        _enquiries.add({
          'enquiry': enquiryText,
          'status': 'Submitted', // Initially setting the status to 'Submitted'
        });
        _enquiryController.clear(); // Clear the text field after submission
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your enquiry has been submitted.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid enquiry or complaint.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Enquiry & Complaints'),
        backgroundColor: Color.fromARGB(255, 245, 184, 93),
      ),
      body: Container(
        // This Container will now fully cover the screen.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 245, 184, 93),
              const Color.fromARGB(255, 233, 211, 88),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        constraints: BoxConstraints.expand(), // Ensures the container takes up all space.
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildEnquiryForm(),
              SizedBox(height: 20),
              _buildEnquiryList(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for the enquiry form where users can enter their complaint or enquiry
  Widget _buildEnquiryForm() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit Your Enquiry or Complaint',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _enquiryController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your enquiry or complaint here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitEnquiry,
              child: Text(
                'Submit Enquiry',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
               
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the list of submitted enquiries/complaints
  Widget _buildEnquiryList() {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Submitted Enquiries/Complaints:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (_enquiries.isEmpty)
              Text('No enquiries/complaints submitted yet.'),
            for (int i = 0; i < _enquiries.length; i++)
              _buildEnquiryItem(i),
          ],
        ),
      ),
    );
  }

  // Widget for displaying individual enquiry items
  Widget _buildEnquiryItem(int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _enquiries[index]['enquiry']!,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Status: ${_enquiries[index]['status']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
