import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnquiryPage extends StatefulWidget {
  final String shop_id;

  const EnquiryPage({super.key, required this.shop_id});

  @override
  _EnquiryPageState createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  TextEditingController messageController = TextEditingController();
  String? shopName;
  String? shopId;

  @override
  void initState() {
    super.initState();
    fetchShopId(); // Fetch shop_id from SharedPreferences
  }

  // Fetch the shop_id from SharedPreferences
  Future<void> fetchShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shopId = prefs.getString('shop_id'); // Assuming shop_id is saved as 'shop_id'
    });

    if (shopId != null) {
      fetchShopName(); // Only fetch shopName if shopId is available
    }
  }

  // Fetch the shop name using the shop_id from the Shop Owner collection
  Future<void> fetchShopName() async {
    if (shopId != null) {
      try {
        // Query the Shop Owner collection based on shop_id field
        QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
            .collection('Shop Owner')
            .where('shop_id', isEqualTo: shopId)
            .get();

        if (shopSnapshot.docs.isNotEmpty) {
          setState(() {
            shopName = shopSnapshot.docs[0]['store_name']; // Assuming 'store_name' field exists
            print("Fetched Store Name: $shopName");
          });
        } else {
          setState(() {
            shopName = 'Shop Not Found';
          });
        }
      } catch (e) {
        print("Error fetching shop name: $e");
      }
    }
  }

  // Submit message to Firestore
  Future<void> submitMessage(String content) async {
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please provide the content of your message."),
      ));
      return;
    }

    if (shopName == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Unable to retrieve store name. Please try again."),
      ));
      return;
    }

    try {
      // Add the data to the "messages" collection in Firestore
      await FirebaseFirestore.instance.collection('messages').add({
        'shop_id': shopId,
        'store_name': shopName, // Ensure store_name is not null here
        'sender': 'shop_owner', // You can change this depending on the sender role
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Message sent successfully!"),
      ));

      // Clear text field
      messageController.clear();
    } catch (e) {
      print("Error submitting message: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sending message. Please try again."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Message Admin'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display shop name (if fetched)
              if (shopName != null)
                Text(
                  'Hello, $shopName',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              SizedBox(height: 20),

              // Message Section in a Card
              _buildMessageCard(),

              SizedBox(height: 20),

              // Enquiry Messages Section
              _buildEnquiryMessages(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build the message section with a text field and submit button
  Widget _buildMessageCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Colors.deepPurpleAccent),
                SizedBox(width: 10),
                Text(
                  'Send a Message to Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your message here...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurpleAccent),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => submitMessage(messageController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Send Message',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build the list of previously sent messages
  Widget _buildEnquiryMessages() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('messages')
          .where('shop_id', isEqualTo: widget.shop_id)
          .orderBy('timestamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching messages.'));
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Center(child: Text('No messages found.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final sender = message['sender'] ?? 'Unknown';
            final content = message['content'] ?? 'No content';
            final timestamp = message['timestamp'] ?? DateTime.now();

            return Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.message, color: Colors.deepPurpleAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From: $sender',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(content),
                          SizedBox(height: 5),
                          Text(
                            'Sent on: ${timestamp.toDate()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
