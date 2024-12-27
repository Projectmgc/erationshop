import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  // A list of family members. This will be fetched from Firestore.
  List<Map<String, String>> familyMembers = [];
  
  // List of approved and rejected requests
  List<Map<String, dynamic>> approvedRequests = [];
  List<Map<String, dynamic>> rejectedRequests = [];

  // Flags to check if the data is loaded
  bool isLoading = true;
  String? userCardNo;

  // Retrieve the card_no from SharedPreferences
  Future<String?> _getUserCardNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('card_no'); // 'card_no' is the key used to store the card number
  }

  // Fetch card data from Firestore using the card number
  Future<Map<String, dynamic>?> _getUserCardData(String cardNo) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Card')
          .where('card_no', isEqualTo: cardNo)
          .limit(1)
          .get();
      if (docSnapshot.docs.isNotEmpty) {
        return docSnapshot.docs.first.data() as Map<String, dynamic>?; // Return card data
      } else {
        return null; // If card doesn't exist
      }
    } catch (e) {
      print('Error fetching card data: $e');
      return null; // In case of any error
    }
  }

  // Fetch pending, approved, and rejected requests from Firestore
  Future<void> _fetchRequests(String cardNo) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('RequestMember')
          .where('card_no', isEqualTo: cardNo)
          .get();

      setState(() {
        approvedRequests = [];
        rejectedRequests = [];

        // Process the requests and categorize them into approved and rejected
        for (var doc in querySnapshot.docs) {
          final request = doc.data() as Map<String, dynamic>;
          if (request['status'] == 'approved') {
            approvedRequests.add(request);
          } else if (request['status'] == 'rejected') {
            rejectedRequests.add(request);
          }
        }
      });
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  // Initialize the state and fetch the user card data and requests
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data once on widget initialization
  Future<void> _loadUserData() async {
    final cardNo = await _getUserCardNo();
    if (cardNo != null) {
      setState(() {
        userCardNo = cardNo;
      });

      final cardData = await _getUserCardData(cardNo);
      if (cardData != null) {
        setState(() {
          familyMembers = List.generate(
            int.parse(cardData['members_count']),
            (index) => {
              'name': 'Member $index',
              'id': 'ID${index + 1}',
            },
          );
        });
        // Fetch approved and rejected requests once the card data is loaded
        _fetchRequests(cardNo);
      }
      setState(() {
        isLoading = false; // Data is now loaded
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to add a new family member
  void _addMember(String name, String id, String cardno) async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('RequestMember').add({
        'card_no': cardno,
        'member_id': id,
        'member_name': name,
        'timestamp': FieldValue.serverTimestamp(), // Add the current server timestamp
        'status': 'pending', // Default status is 'pending'
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error adding member: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ration Cards'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : userCardNo == null
              ? const Center(child: Text('No card number found in preferences'))
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 245, 184, 93),
                        Color.fromARGB(255, 233, 211, 88),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cardholder: ${familyMembers.isNotEmpty ? familyMembers[0]['name'] : 'Loading...'}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Card Number: $userCardNo',
                        style: const TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Family Members',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: familyMembers.length,
                          itemBuilder: (context, index) {
                            final member = familyMembers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(member['name']!),
                                subtitle: Text('id: ${member['id']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      familyMembers.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddMemberDialog(context);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Member'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Approved Requests',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: approvedRequests.length,
                        itemBuilder: (context, index) {
                          final request = approvedRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            child: ListTile(
                              title: Text(request['member_name']),
                              subtitle: Text('ID: ${request['member_id']}'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Rejected Requests',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rejectedRequests.length,
                        itemBuilder: (context, index) {
                          final request = rejectedRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            child: ListTile(
                              title: Text(request['member_name']),
                              subtitle: Text('ID: ${request['member_id']}'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  // Show dialog to add a new member
  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Family Member'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter family member\'s name',
                ),
              ),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Adhar number',
                  hintText: 'Enter family member\'s ID',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final id = idController.text.trim();
                if (name.isNotEmpty && id.isNotEmpty) {
                  _addMember(name, id, userCardNo!);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 245, 184, 93),
            Color.fromARGB(255, 233, 211, 88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
