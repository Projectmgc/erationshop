import 'package:erationshop/admin/screens/admin_autherisation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Requests", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('RequestMember')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No requests available", style: TextStyle(fontSize: 18, color: Colors.grey)));
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var request = requests[index];
                var cardNo = request['card_no'] ?? 'No card number';
                var memberName = request['member_name'] ?? 'No name';
                var mobileNo = request['mobile_no'] ?? 'No mobile number';
                var requestType = request['request_type'] ?? 'No type';
                var status = request['status'] ?? 'No status';
                var timestamp = (request['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to the request approval page with the request details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailPage(
                            requestId: request.id,
                            cardNo: cardNo,
                            memberName: memberName,
                            mobileNo: mobileNo,
                            requestType: requestType,
                            status: status,
                            timestamp: timestamp,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade200, Colors.deepPurple.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Card No: $cardNo",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(context, request.id);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Member Name: $memberName",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Mobile No: $mobileNo",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Request Type: $requestType",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: status == 'pending' ? Colors.orange : Colors.green,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "${timestamp.toLocal()}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                         
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Show confirmation dialog before deleting
  void _confirmDelete(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text("Are you sure you want to delete this request?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Delete the request from Firestore
                await FirebaseFirestore.instance.collection('RequestMember').doc(requestId).delete();
                Navigator.of(context).pop(); // Close the dialog after deletion
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request deleted successfully")));
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
