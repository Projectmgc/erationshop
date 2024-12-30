import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erationshop/admin/screens/admin_product.dart';
import 'package:erationshop/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  // List of family members to be fetched from Firestore
  List<Map<String, String>> familyMembers = [];

  // List of approved and rejected requests
  List<Map<String, dynamic>> approvedRequests = [];
  List<Map<String, dynamic>> rejectedRequests = [];

  // Flags to check if the data is loaded
  bool isLoading = true;
  String? userCardNo;

  // Card details
  Map<String, dynamic>? cardData;

  // Retrieve the card_no from SharedPreferences
  Future<String?> _getUserCardNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('card_no'); // 'card_no' is the key used to store the card number
  }

  // Fetch card data from Firestore using the card number
  Future<Map<String, dynamic>?> _getUserCardData(String cardNo) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Card')
          .where('card_no', isEqualTo: cardNo)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>?; // Return card data
      } else {
        return null; // If card doesn't exist
      }
    } catch (e) {
      print('Error fetching card data: $e');
      return null; // In case of any error
    }
  }

  // Fetch family members from the member_list sub-collection in Firestore
  Future<void> _fetchFamilyMembers(String cardNo) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Card')
          .where('card_no', isEqualTo: cardNo) // Use card_no field to fetch the document
          .limit(1) // Make sure only one document is returned (since card_no is unique)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final cardDoc = querySnapshot.docs.first; // Get the first (and only) document

        // Now fetch the family members from the 'member_list' sub-collection
        final memberSnapshot = await cardDoc.reference
            .collection('member_list')
            .get();

        setState(() {
          // Populate the familyMembers list with the fetched data
          familyMembers = memberSnapshot.docs.map((doc) {
            return {
              'member_name': doc['member_name']?.toString() ?? 'N/A',
              'mobile_no': doc['mobile_no']?.toString() ?? 'N/A',
              'member_id': doc.id, // Save the document ID for later reference
            };
          }).toList();
        });
      } else {
        print('No card document found for card_no: $cardNo');
        setState(() {
          familyMembers = [];
        });
      }
    } catch (e) {
      print('Error fetching family members: $e');
      setState(() {
        familyMembers = [];
      });
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
          this.cardData = cardData; // Store the card data
        });
        // Fetch family members and requests once the card data is loaded
        _fetchFamilyMembers(cardNo);
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
  void _addMember(String memberName, String mobileNo, String userCardNo) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Add the request to the 'RequestMember' collection for adding a member
      await FirebaseFirestore.instance.collection('RequestMember').add({
        'card_no': userCardNo, // Card number to associate the request with the card
        'member_name': memberName,
        'mobile_no': mobileNo,
        'status': 'pending', // Default status can be 'pending' until approved or rejected
        'request_type': 'add',
        'timestamp': FieldValue.serverTimestamp(), // Add the current server timestamp
      });

      setState(() {
        isLoading = false;
      });

      // After adding a member, fetch updated family members list
      _fetchFamilyMembers(userCardNo);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error adding member: $e');
    }
  }

  // Function to send a deletion request for a family member
  void _deleteMember(String memberName, String mobileNo, String userCardNo) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Send a deletion request to the 'RequestMember' collection
      await FirebaseFirestore.instance.collection('RequestMember').add({
        'card_no': userCardNo, // Card number to associate the request with the card
        'member_name': memberName,
        'mobile_no': mobileNo,
        'status': 'pending', // Set the status to pending for review
        'request_type': 'delete', // Specify the request type as 'delete'
        'timestamp': FieldValue.serverTimestamp(), // Add the current server timestamp
      });

      setState(() {
        isLoading = false;
      });

      // After sending the deletion request, fetch updated family members list
      _fetchFamilyMembers(userCardNo!);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error deleting member: $e');
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
          : card_no == null
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
                      // Card details section
                      cardData != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cardholder: ${cardData!['owner_name'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Card Type: ${cardData!['category'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black87),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Card Number: $userCardNo',
                                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const Center(child: Text('Loading Card Details...')),

                      // Family members section
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
                                title: Text(member['member_name']!),
                                subtitle: Text('Mobile: ${member['mobile_no']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Send the delete request for this member
                                    _deleteMember(member['member_name']!, member['mobile_no']!, userCardNo!,);
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
                              subtitle: Text('ID: ${request['mobile_no']}'),
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
    final mobileNoController = TextEditingController();

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
                  labelText: 'Member Name',
                  hintText: 'Enter family member\'s name',
                ),
              ),
              TextField(
                controller: mobileNoController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'Enter family member\'s mobile number',
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
                final memberName = nameController.text.trim();
                final mobileNo = mobileNoController.text.trim();
                if (memberName.isNotEmpty && mobileNo.isNotEmpty) {
                  _addMember(memberName, mobileNo, userCardNo!);
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
