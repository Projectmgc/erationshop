import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  // Fetch enquiries from Firestore
  Future<List<Map<String, dynamic>>> _fetchComplaints() async {
    // Get a reference to the Firestore collection 'Enquiries'
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Enquiries')
        .orderBy('timestamp', descending: true)
        .get();

    // Map the Firestore data into a list of complaints
    return querySnapshot.docs.map((doc) {
      // Safely access each field and provide a default value if null
      return {
        'subject': doc['subject'] != null ? doc['subject'] : 'No subject provided',  // 'subject' field now
        'status': doc['status'] != null ? doc['status'] : 'No status provided',      // Provide a default value if 'status' is null
        'timestamp': doc['timestamp'],                         // Timestamp (can be null, handled below)
        'description': doc['description'] != null ? doc['description'] : 'No description provided', // Default value if 'description' is null
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Complaints'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchComplaints(),  // Fetch complaints from Firestore
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
                    leading: Icon(
                      Icons.report_problem, // Icon for complaint type
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      complaint['subject'], // Displaying the 'subject' text
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${complaint['status']}'), // Displaying the status
                        const SizedBox(height: 5),
                        Text(
                          'Filed on: ${complaint['timestamp']?.toDate().toString() ?? 'No timestamp available'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      // Pass the complaint details to the ComplaintDetailsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailsPage(
                            complaint: complaint, // Pass the full complaint data
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
    );
  }
}

class ComplaintDetailsPage extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailsPage({required this.complaint, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
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
              'Subject: ${complaint['subject']}',  // Accessing 'subject' safely
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${complaint['status']}',  // Accessing 'status' safely
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Description:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              complaint['description'] ?? 'No description provided',  // Handle nullable description
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Filed on: ${complaint['timestamp']?.toDate().toString() ?? 'No timestamp available'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complaint action pending...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Mark as Resolved'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
