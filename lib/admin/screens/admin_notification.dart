import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  _AdminNotificationPageState createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage> {
  // Controllers for text fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add notification to Firestore
  Future<void> addNotification() async {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      try {
        // Add notification data to Firestore 'Notifications' collection
        await _firestore.collection('Notifications').add({
          'title': titleController.text,
          'content': contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the text fields after posting
        titleController.clear();
        contentController.clear();
      } catch (e) {
        // Show error if there is an issue with the Firestore operation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post notification: $e')),
        );
      }
    } else {
      // Show a simple validation error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
    }
  }

  // Function to delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Delete the notification from Firestore
      await _firestore.collection('Notifications').doc(notificationId).delete();
    } catch (e) {
      // Show error if there is an issue with the Firestore operation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: $e')),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading notifications.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No notifications yet.'));
                  }

                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final notificationId = notification.id; // Get the notification ID
                      final title = notification['title'] ?? 'No Title';
                      final content = notification['content'] ?? 'No Content';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(content),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Confirm before deleting
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Notification'),
                                    content: const Text('Are you sure you want to delete this notification?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await deleteNotification(notificationId);
                                          Navigator.pop(context); // Close the dialog
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
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
