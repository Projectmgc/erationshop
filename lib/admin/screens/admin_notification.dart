import 'package:flutter/material.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  _AdminNotificationPageState createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  // List to store the notifications
  final List<Map<String, String>> notifications = [];

  // Controllers for text fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Function to add notification to the list
  void addNotification() {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      setState(() {
        notifications.add({
          'title': titleController.text,
          'content': contentController.text,
        });
      });
      // Clear the text fields after posting
      titleController.clear();
      contentController.clear();
    } else {
      // Show a simple validation error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field for notification title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Input field for notification content
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Notification Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 4, // Allow multiple lines for content
            ),
            const SizedBox(height: 16),
            // Button to post the notification
            ElevatedButton(
              onPressed: addNotification,
              child: const Text('Post Notification'),
            ),
            const SizedBox(height: 32),
            // Display list of posted notifications
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(notification['title']!),
                      subtitle: Text(notification['content']!),
                    ),
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
