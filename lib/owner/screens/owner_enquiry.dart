import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnquiryPage extends StatefulWidget {
  final String shopId; // Passed shopId to the page

  EnquiryPage({required this.shopId});

  @override
  _EnquiryPageState createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final TextEditingController _messageController = TextEditingController();
  late Stream<QuerySnapshot> _enquiriesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to fetch enquiries for the given shop_id
    _enquiriesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('shop_id', isEqualTo: widget.shopId) // Query based on shop_id
        .orderBy('timestamp', descending: true) // Optional: Order by timestamp
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enquiry Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Your Enquiry',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String content = _messageController.text.trim();

                if (content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a message!")),
                  );
                  return;
                }

                // Submit the enquiry to Firestore with shopId
                try {
                  await FirebaseFirestore.instance.collection('messages').add({
                    'content': content,
                    'timestamp': FieldValue.serverTimestamp(),
                    'shop_id': widget.shopId, // Use widget.shopId to access the passed parameter
                    'status': 'pending',
                    'reply': '', // Space for reply
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enquiry submitted successfully!")),
                  );
                  _messageController.clear(); // Clear the message field after submission
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error submitting enquiry: $e")),
                  );
                }
              },
              child: Text('Submit Enquiry'),
            ),
            SizedBox(height: 30),
            Text(
              'Submitted Enquiries:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display enquiries in a ListView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _enquiriesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No enquiries found."));
                  }

                  // Get the list of enquiries documents
                  final enquiries = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: enquiries.length,
                    itemBuilder: (context, index) {
                      final enquiry = enquiries[index];
                      final content = enquiry['content'];
                      final timestamp = enquiry['timestamp']?.toDate();
                      final status = enquiry['status'];
                      final reply = enquiry['reply'];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(content),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Timestamp: ${timestamp != null ? timestamp.toString() : 'N/A'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Status: $status',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (reply.isNotEmpty) ...[
                                SizedBox(height: 5),
                                Text(
                                  'Reply: $reply',
                                  style: TextStyle(fontSize: 14, color: Colors.blue),
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
