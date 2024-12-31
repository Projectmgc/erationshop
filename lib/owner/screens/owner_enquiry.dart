import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnquiryPage extends StatefulWidget {
  const EnquiryPage({super.key});

  @override
  _EnquiryPageState createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String shopId = '';  // Initialize shopId to an empty string
  String shopOwnerName = '';  // To store the shop owner's name
  late CollectionReference chatCollection;

  /// Fetch shopId and shop owner name from SharedPreferences
void _getShopIdAndName() async {
  // Fetch shopId from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    shopId = prefs.getString('shop_id') ?? '';  // Fetch and set shopId
  });
  
  print(shopId);
   print(shopId);
    print(shopId);
     print(shopId);
      print(shopId);
       print(shopId);
        print(shopId);
         print(shopId);
  // Fetch the shop owner's name using the shopId
  if (shopId.isNotEmpty) {
    // Query the Shop Owner collection to get the shop owner's document by shop_id
    QuerySnapshot shopOwnerSnapshot = await _firestore
        .collection('Shop Owner')
        .where('shop_id', isEqualTo: shopId)  // Match the shop_id field
        .limit(1)  // Ensure only one document is returned
        .get();

    if (shopOwnerSnapshot.docs.isNotEmpty) {
      DocumentSnapshot shopOwnerDoc = shopOwnerSnapshot.docs.first;

      // Retrieve shop owner's name and set it
      setState(() {
        shopOwnerName = shopOwnerDoc['name'] ?? 'Unknown';  // Retrieve shop owner's name
      });

      print(shopOwnerName);
      print(shopOwnerName);
      print(shopOwnerName);
      print(shopOwnerName);
      print(shopOwnerName);
      print(shopOwnerName);
      print(shopOwnerName);
      print(shopOwnerName);

      print(shopOwnerName);

      // Initialize Firestore collection for messages using the shopId
      chatCollection = _firestore.collection('converse').doc(shopId).collection('messages');
    } else {
      // Handle case where no shop owner is found
      print('No shop owner found for shop_id: $shopId');
    }
  }
}



  @override
  void initState() {
    super.initState();
    _getShopIdAndName();  // Fetch shopId and shop owner name as soon as the screen is initialized
  }

  // Function to send message
  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty && shopId.isNotEmpty) {  // Check if shopId is not empty
      String messageText = _controller.text.trim();
      String sender = shopOwnerName.isNotEmpty ? shopOwnerName : 'Shop Owner';  // Use shop owner name as sender

      // Send message to Firestore under the respective shop's collection
      await chatCollection.add({
        'shop_id': shopId,
        'sender': sender,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the input field after sending the message
      _controller.clear();
    }
  }

  // Function to build message bubbles based on sender type
  Widget _buildMessageBubble(String sender, String message) {
    return Align(
      alignment: sender == 'Admin' ? Alignment.topLeft : Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Material(
          color: sender == 'Admin' ? Colors.blueAccent.shade100 : Colors.greenAccent.shade100,
          borderRadius: BorderRadius.circular(15),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Admin"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          // Chat messages list
         Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: (shopId.isNotEmpty && chatCollection != null) 
      ? chatCollection.orderBy('timestamp').snapshots()
      : null,  // Only listen to the collection if chatCollection is not null
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No messages yet.'));
      }

      final messages = snapshot.data!.docs;
      return ListView.builder(
        reverse: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final sender = message['sender'] as String;
          return _buildMessageBubble(sender, message['message'] as String);
        },
      );
    },
  ),
),

          
          // Message input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example of how to navigate to this EnquiryPage from another screen:

// This is an example function to navigate to the EnquiryPage, which accepts shopId.
void navigateToChatPage(BuildContext context, String shopId) {
  if (shopId.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnquiryPage(),
      ),
    );
  } else {
    // Handle invalid shopId (if needed)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid shop ID!')),
    );
  }
}
