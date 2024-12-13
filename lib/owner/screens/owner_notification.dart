/*import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification")),
      body: Center(child: Text("Notification Page")),
    );
  }
}
*/
import 'package:flutter/material.dart';

class OwnerNotification extends StatefulWidget {
  const OwnerNotification({super.key});

  @override
  _OwnerNotificationState createState() => _OwnerNotificationState();
}

class _OwnerNotificationState extends State<OwnerNotification> {
  // Define a list of notifications with title and content
  List<NotificationItem> notifications = [
    NotificationItem(
      title: 'New Item available in stores',
      content: 'new item available in stores ',
    ),
    
    NotificationItem(
      title: 'Application Update Available',
      content: 'A new Application update is ready to install. Update now!',
    ),
  ];

  // Toggle expansion of content for each notification
  void toggleExpansion(int index) {
    setState(() {
      notifications[index].isExpanded = !notifications[index].isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 184, 93),
      appBar: AppBar(
        title: const Text("Notification"),
        backgroundColor: const Color.fromARGB(255, 245, 184, 93),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 182, 229, 238),  // Standard background color for the notification item
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: InkWell(
              onTap: () => toggleExpansion(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      notification.title,
                      style: const TextStyle(
                        fontFamily: 'Roboto', // Custom font, you can change this to any other font family
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color.fromARGB(255, 56, 46, 2), // Set title text color to black for readability
                      ),
                    ),
                    trailing: Icon(
                      notification.isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: const Color.fromARGB(255, 56, 40, 2), // Icon color
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        notification.content,
                        style: const TextStyle(
                          color: Colors.black, // Text color for content
                          fontSize: 16,
                        ),
                      ),
                    ),
                    crossFadeState: notification.isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Model class for notification item
class NotificationItem {
  final String title;
  final String content;
  bool isExpanded;

  NotificationItem({
    required this.title,
    required this.content,
    this.isExpanded = false,
  });
}
