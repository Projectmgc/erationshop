import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  // Fetch complaints from Firestore
  Future<List<Map<String, dynamic>>> _fetchComplaints() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Enquiries')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return {
        'subject': doc['subject'] != null ? doc['subject'] : 'No subject provided',
        'status': doc['status'] != null ? doc['status'] : 'No status provided',
        'timestamp': doc['timestamp'],
        'description': doc['description'] != null
            ? doc['description']
            : 'No description provided',
        'complaintId': doc.id, // Adding the document ID for reference
        'response': doc['response'], // Adding response data for display
        'cardNo': doc['card_no'], // Adding card number
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Complaints'),
        backgroundColor: const Color.fromARGB(255, 245, 184, 93),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
                  const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchComplaints(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching complaints'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No complaints available'));
            } else {
              final complaints = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: complaint['response'] == null
                          ? Icon(
                              Icons.report_problem,
                              color: Colors.redAccent,
                            )
                          : Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                      title: Text(
                        complaint['subject'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${complaint['status']}'),
                          const SizedBox(height: 5),
                          Text(
                            'Filed on: ${complaint['timestamp']?.toDate().toString() ?? 'No timestamp available'}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (complaint['response'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Response: ${complaint['response']}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green),
                              ),
                            ),
                          // Display Card Number
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Card No: ${complaint['cardNo']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailsPage(
                              complaint: complaint,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ComplaintDetailsPage extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailsPage({required this.complaint, super.key});

  @override
  _ComplaintDetailsPageState createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  final TextEditingController _responseController = TextEditingController();

  // Submit the response and update the complaint status to 'Resolved'
  Future<void> _submitResponse() async {
    if (_responseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response before submitting')),
      );
      return;
    }

    try {
      // Get the document reference for the current complaint
      final complaintRef = FirebaseFirestore.instance
          .collection('Enquiries')
          .doc(widget.complaint['complaintId']);

      // Update the document with the response and set the status to 'Resolved'
      await complaintRef.update({
        'response': _responseController.text,
        'responseTimestamp': FieldValue.serverTimestamp(),
        'status': 'Resolved', // Changing the status to 'Resolved'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response submitted successfully')),
      );

      // Optionally, clear the text field after submission
      _responseController.clear();

      // Reload the current complaint to reflect the changes
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting response')),
      );
    }
  }

  // Delete the complaint from Firestore
  Future<void> _deleteComplaint() async {
    try {
      final complaintRef = FirebaseFirestore.instance
          .collection('Enquiries')
          .doc(widget.complaint['complaintId']);

      // Delete the complaint document
      await complaintRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint deleted successfully')),
      );

      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting complaint')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the complaint already has a response
    bool isResponded = widget.complaint['response'] != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: const Color.fromARGB(255, 245, 184, 93),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
                  const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),// End color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complaint Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Subject: ${widget.complaint['subject']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Status: ${widget.complaint['status']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Description:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.complaint['description'] ?? 'No description provided',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Filed on: ${widget.complaint['timestamp']?.toDate().toString() ?? 'No timestamp available'}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text(
                'Card Number: ${widget.complaint['cardNo']}',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              const Text(
                'Response:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.complaint['response'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.complaint['response']!,
                    style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.green),
                  ),
                )
              else
                const Text('No response yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),
              if (!isResponded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submit Response:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _responseController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Enter your response here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitResponse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: const Text('Submit Response'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Delete button
              Center(
                child: ElevatedButton(
                  onPressed: _deleteComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Delete Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
