import 'package:flutter/material.dart';

class EnquiryPage extends StatefulWidget {
  const EnquiryPage({super.key});

  @override
  _EnquiryPageState createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'Admin', 'message': 'Hello, how can I assist you today?'},
    {'sender': 'Owner', 'message': 'I have a question regarding my order.'},
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'Owner',
          'message': _controller.text,
        });
        _controller.clear();
      });
    }
  }

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
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message['sender']!, message['message']!);
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
