import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminRequest extends StatefulWidget {
  const AdminRequest({super.key});

  @override
  _AdminRequestState createState() => _AdminRequestState();
}

class _AdminRequestState extends State<AdminRequest> {
  // List of member requests pending approval
  List<Map<String, dynamic>> pendingRequests = [];

  // Fetch all pending member requests from Firestore
  Future<void> _fetchPendingRequests() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('RequestMember') // Fetching from the RequestMember collection
          .where('status', isEqualTo: 'pending') // Filtering only pending requests
          .orderBy('timestamp', descending: true) // Sorting by timestamp in descending order
          .get();

      setState(() {
        pendingRequests = querySnapshot.docs.map((doc) {
          return {
            'card_no': doc['card_no'],
            'member_id': doc['member_id'],
            'member_name': doc['member_name'],
            'request_id': doc.id,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching pending requests: $e');
    }
  }

  // Approve the member request and update Firestore
  Future<void> _approveRequest(String requestId) async {
    try {
      // Update the status to 'approved' in RequestMember collection
      await FirebaseFirestore.instance.collection('RequestMember').doc(requestId).update({
        'status': 'approved', // Change status to approved
        'approval_timestamp': FieldValue.serverTimestamp(), // Add approval timestamp
      });

      // Refresh the pending requests after approval
      _fetchPendingRequests();

      print('Request approved!');
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  // Reject the member request and update Firestore
  Future<void> _rejectRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('RequestMember').doc(requestId).update({
        'status': 'rejected', // Change status to rejected
        'rejection_timestamp': FieldValue.serverTimestamp(), // Add rejection timestamp
      });

      // Refresh the pending requests after rejection
      _fetchPendingRequests();

      print('Request rejected!');
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests(); // Fetch the pending requests when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Member Requests'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: pendingRequests.isEmpty
          ? const Center(child: Text('No pending requests')) // Show message if no requests
          : ListView.builder(
              itemCount: pendingRequests.length, // Number of requests to display
              itemBuilder: (context, index) {
                final request = pendingRequests[index]; // Get each request from the list
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text(request['member_name']), // Member's name
                    subtitle: Text('ID: ${request['member_id']}'), // Member's ID
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Approve button
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _approveRequest(request['request_id']); // Approve the request
                          },
                        ),
                        // Reject button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _rejectRequest(request['request_id']); // Reject the request
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
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
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 245, 184, 93),
            Color.fromARGB(255, 233, 211, 88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
