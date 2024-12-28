import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestDetailPage extends StatefulWidget {
  final String requestId;

  const RequestDetailPage({super.key, required this.requestId, required DateTime timestamp, required status, required mobileNo, required memberName, required cardNo});

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
        // Step 2: Add the new member to the member_list sub-collection using set()
        transaction.set(
          memberListRef.doc(), // Use memberId (mobile_no) as the document ID
          {
            'mobile_no': memberId,
            'member_name': memberName,
            // No added_timestamp here
          },
        );

        // Step 3: Update the members_count by fetching the current member count and incrementing it
        final currentMemberCount = int.tryParse(cardDocSnapshot['members_count'] ?? '0') ?? 0;
        final updatedMemberCount = currentMemberCount + 1;

        // Only update members_count, nothing else in the Card collection
        transaction.update(cardDocRef, {
          'members_count': updatedMemberCount.toString(),  // Update as string since it's a string field in Firestore
        });
      });

      // Step 4: Update the status of the request to 'approved' in RequestMember collection
      await FirebaseFirestore.instance.collection('RequestMember').doc(widget.requestId).update({
        'status': 'approved',
        'approval_timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Go back to the previous screen after approval
      print('Request approved and member added!');
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  // Reject the request and update Firestore
  Future<void> _rejectRequest() async {
    try {
      await FirebaseFirestore.instance.collection('RequestMember').doc(widget.requestId).update({
        'status': 'rejected',
        'rejection_timestamp': FieldValue.serverTimestamp(),
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
