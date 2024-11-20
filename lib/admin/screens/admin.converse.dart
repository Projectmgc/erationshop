/*import 'package:flutter/material.dart';

class ConversePage extends StatelessWidget {
  const ConversePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Converse')),
      body: Center(child: const Text('Converse Page Content')),
    );
  }
}
*/
import 'package:flutter/material.dart';

class ConversePage extends StatefulWidget {
  const ConversePage({super.key});

  @override
  State<ConversePage> createState() => _ConversePageState();
}

class _ConversePageState extends State<ConversePage> {
  // Sample data for shop owners
  final List<Map<String, String>> shopOwners = [
    {'name': 'John Doe', 'store': 'Doe Grocery'},
    {'name': 'Jane Smith', 'store': 'Smith Supermart'},
    {'name': 'Robert Brown', 'store': 'Brown Supplies'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owners'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: shopOwners.length,
        itemBuilder: (context, index) {
          final shopOwner = shopOwners[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.deepPurpleAccent),
              title: Text(shopOwner['name']!),
              subtitle: Text('Store: ${shopOwner['store']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                // Navigate to chat page for the selected shop owner
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopOwnerChatPage(
                      shopOwner: shopOwner,
                    ),
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

class ShopOwnerChatPage extends StatefulWidget {
  final Map<String, String> shopOwner;

  const ShopOwnerChatPage({required this.shopOwner, super.key});

  @override
  State<ShopOwnerChatPage> createState() => _ShopOwnerChatPageState();
}

class _ShopOwnerChatPageState extends State<ShopOwnerChatPage> {
  final List<Map<String, String>> messages = [
    {'sender': 'Admin', 'message': 'Hello, how can I assist you today?'},
    {'sender': 'Shop Owner', 'message': 'I need help updating my inventory.'},
  ];

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({'sender': 'Admin', 'message': _messageController.text.trim()});
        _messageController.clear();
      });
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
            child: ListView.builder(
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
