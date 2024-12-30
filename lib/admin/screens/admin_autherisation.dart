import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestDetailPage extends StatefulWidget {
  final String requestId;

  const RequestDetailPage({
    super.key,
    required this.requestId,
    required DateTime timestamp,
    required status,
    required mobileNo,
    required memberName,
    required cardNo,
    required requestType,
  });

  @override
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  Map<String, dynamic> requestDetails = {};

  // Fetch the request details from Firestore
  Future<void> _fetchRequestDetails() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('RequestMember')
          .doc(widget.requestId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          requestDetails = docSnapshot.data()!;
        });
      }
    } catch (e) {
      print('Error fetching request details: $e');
    }
  }

  // Approve the request and update Firestore
  Future<void> _approveRequest() async {
    try {
      final cardNo = requestDetails['card_no'];
      final memberId = requestDetails['mobile_no']; // Using 'mobile_no' as member identifier
      final memberName = requestDetails['member_name'];

      // Step 1: Find the Card document based on card_no field in the collection
      final cardQuerySnapshot = await FirebaseFirestore.instance
          .collection('Card')
          .where('card_no', isEqualTo: cardNo)
          .limit(1)  // Limit to 1 document as there should only be one match
          .get();

      if (cardQuerySnapshot.docs.isEmpty) {
        throw Exception('Card not found');
      }

      // Get the Card document from the query
      final cardDocSnapshot = cardQuerySnapshot.docs.first;
      final cardDocRef = cardDocSnapshot.reference;
      final memberListRef = cardDocRef.collection('member_list'); // member_list as a sub-collection

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        if (requestDetails['request_type'] == 'add') {
          // Step 2: Add the new member to the member_list sub-collection using set()
          transaction.set(
            memberListRef.doc(), // Create a new document for the member in member_list
            {
              'mobile_no': memberId,
              'member_name': memberName,
            },
          );
        } else if (requestDetails['request_type'] == 'delete') {
          // Handle delete request (delete member from the list)
          final memberDocSnapshot = await memberListRef
              .where('mobile_no', isEqualTo: memberId)
              .limit(1)
              .get();

          if (memberDocSnapshot.docs.isNotEmpty) {
            // Step 3: If the member is found, delete the member document
            transaction.delete(memberDocSnapshot.docs.first.reference);
          } else {
            throw Exception('Member not found in member list');
          }
        }

        // Step 4: Update the status of the request to 'approved' in RequestMember collection
        transaction.update(FirebaseFirestore.instance.collection('RequestMember').doc(widget.requestId), {
          'status': 'approved',
        });
      });

      Navigator.pop(context); // Go back to the previous screen after approval
      print('Request approved!');
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  // Reject the request and update Firestore
  Future<void> _rejectRequest() async {
    try {
      await FirebaseFirestore.instance.collection('RequestMember').doc(widget.requestId).update({
        'status': 'rejected',
      });

      Navigator.pop(context); // Go back to the previous screen after rejection
      print('Request rejected!');
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails(); // Fetch request details on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: requestDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Member Name: ${requestDetails['member_name']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Member ID: ${requestDetails['mobile_no']}'),
                  Text('Card No: ${requestDetails['card_no']}'),
                  const SizedBox(height: 20),
                  Text(
                    'Request Type: ${requestDetails['request_type'] == "add" ? "Add Member" : "Delete Member"}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _approveRequest,
                        child: const Text('Approve'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: _rejectRequest,
                        child: const Text('Reject'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
