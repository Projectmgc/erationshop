import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, String>> _enquiries = [];

  // Firestore instance
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch existing enquiries from Firestore
  Future<void> _fetchEnquiries() async {
    // Fetch the data from the "Enquiries" collection
    QuerySnapshot querySnapshot = await _firestore.collection('Enquiries').orderBy('timestamp', descending: true).get();

    setState(() {
      // Map the fetched data into the local list
      _enquiries = querySnapshot.docs.map((doc) {
        return {
          'subject': doc['subject']?.toString() ?? '',  // Ensure the 'subject' field is cast to String, default to empty string if null
          'description': doc['description']?.toString() ?? '',  // Ensure the 'description' field is cast to String
          'status': doc['status']?.toString() ?? '',    // Ensure the 'status' field is cast to String
        };
      }).toList();
    });
  }

  // Method to handle submission of enquiries or complaints
  void _submitEnquiry() async {
    String subjectText = _subjectController.text.trim();
    String descriptionText = _descriptionController.text.trim();

    if (subjectText.isNotEmpty && descriptionText.isNotEmpty) {
      // Add to Firestore
      await _firestore.collection('Enquiries').add({
        'subject': subjectText,
        'description': descriptionText,
        'status': 'Submitted',
        'timestamp': FieldValue.serverTimestamp(), // Automatically adds timestamp
      });

      // Clear the text fields after submission
      _subjectController.clear();
      _descriptionController.clear();

      // Fetch the updated list of enquiries after submission
      _fetchEnquiries();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your enquiry has been submitted.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both subject and description.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch existing enquiries when the screen is first loaded
    _fetchEnquiries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Enquiry & Complaints'),
        backgroundColor: Color.fromARGB(255, 245, 184, 93),
      ),
      body: Container(
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
        constraints: BoxConstraints.expand(),
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
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Enter the subject (title) of your enquiry...',
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter the detailed description of your enquiry...',
                labelText: 'Description',
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
              style: ElevatedButton.styleFrom(),
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
                    _enquiries[index]['subject']!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _enquiries[index]['description']!,
                    style: TextStyle(fontSize: 14),
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
