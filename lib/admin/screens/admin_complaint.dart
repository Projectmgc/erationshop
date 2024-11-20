import 'package:flutter/material.dart';

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample complaints data
    final List<Map<String, dynamic>> complaints = [
      {
        'type': 'Application',
        'title': 'App crashing frequently',
        'description': 'The application crashes whenever I try to access the card details.',
        'timestamp': '2024-11-17 10:30 AM',
      },
      {
        'type': 'Store',
        'title': 'Incorrect item delivery',
        'description': 'The store delivered the wrong items despite proper order placement.',
        'timestamp': '2024-11-16 3:45 PM',
      },
      {
        'type': 'Application',
        'title': 'Slow loading times',
        'description': 'It takes too long to load the transactions page.',
        'timestamp': '2024-11-15 8:15 PM',
      },
      {
        'type': 'Store',
        'title': 'Overcharging for items',
        'description': 'The store charged extra compared to the price shown in the app.',
        'timestamp': '2024-11-14 2:00 PM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Complaints'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
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
                complaint['type'] == 'Application' ? Icons.phone_android : Icons.store,
                color: complaint['type'] == 'Application' ? Colors.blue : Colors.green,
              ),
              title: Text(
                complaint['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complaint['description']),
                  const SizedBox(height: 5),
                  Text(
                    'Filed on: ${complaint['timestamp']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                // Navigate to a detailed complaint page if necessary
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintDetailsPage(complaint: complaint),
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
              'Type: ${complaint['type']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Title: ${complaint['title']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Description:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              complaint['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Filed on: ${complaint['timestamp']}',
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
