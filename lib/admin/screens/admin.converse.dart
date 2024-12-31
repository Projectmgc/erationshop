import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConversePage extends StatefulWidget {
  const ConversePage({super.key});

  @override
  State<ConversePage> createState() => _ConversePageState();
}

class _ConversePageState extends State<ConversePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owners'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('converse').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No shop owners available.'));
          }

          final shopOwners = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shopOwners.length,
            itemBuilder: (context, index) {
              final shopOwnerDoc = shopOwners[index];
              final shopId = shopOwnerDoc.id;  // This is the dynamic document ID
              final shopName = shopOwnerDoc['name'];
              final storeName = shopOwnerDoc['store'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.store, color: Colors.deepPurpleAccent),
                  title: Text(shopName),
                  subtitle: Text('Store: $storeName'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // Navigate to the chat screen with the selected shop's information
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopOwnerChatPage(
                          shopOwner: {
                            'name': shopName,
                            'store': storeName,
                            'shop_id': shopId,  // Passing the shop document ID (dynamic)
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ShopOwnerChatPage extends StatefulWidget {
  final Map<String, String> shopOwner;

  const ShopOwnerChatPage({required this.shopOwner, super.key});

  @override
  State<ShopOwnerChatPage> createState() => _ShopOwnerChatPageState();
}

class _ShopOwnerChatPageState extends State<ShopOwnerChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late CollectionReference _chatCollection;

  @override
  void initState() {
    super.initState();
    // Initialize Firestore chat collection based on the selected shop's document ID
    _chatCollection = _firestore.collection('converse').doc(widget.shopOwner['shop_id']).collection('messages');
  }

  // Function to send a message
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String messageText = _messageController.text.trim();
      String sender = 'Admin';  // Always from admin

      // Send message to Firestore
      await _chatCollection.add({
        'sender': sender,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the input field
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopOwner['name']} - Chat'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          // Chat display area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatCollection.orderBy('timestamp', descending: true).snapshots(),
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
                    final isAdmin = message['sender'] == 'Admin';
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.deepPurpleAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['sender']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAdmin ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message['message']!,
                              style: TextStyle(
                                color: isAdmin ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.deepPurpleAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
