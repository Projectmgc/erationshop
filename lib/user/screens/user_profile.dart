import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserProfile(),
    );
  }
}

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: const Color.fromARGB(255, 245, 184, 93),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          } else if (!userSnapshot.hasData || userSnapshot.data == null) {
            return Center(child: Text('No data found'));
          } else {
            final userProfile = userSnapshot.data;
            final String name = userProfile?['name'] ?? 'N/A';
            final String cardId = userProfile?['card_id'] ?? '';
            final String email = userProfile?['email'] ?? 'N/A';

            // Fetch card details using the card_id from the User profile
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Card')
                  .doc(cardId)
                  .snapshots(),
              builder: (context, cardSnapshot) {
                if (cardSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (cardSnapshot.hasError) {
                  return Center(child: Text('Error: ${cardSnapshot.error}'));
                } else if (!cardSnapshot.hasData || cardSnapshot.data == null) {
                  return Center(child: Text('Card data not found'));
                } else {
                  final cardData = cardSnapshot.data;
                  final String cardNumber = cardData?['card_no'] ?? '**** **** ****';
                  final String mobileNumber = cardData?['mobile_no'] ?? 'N/A';
                  final String ownerName = cardData?['owner_name'] ?? 'N/A';
                  final String category = cardData?['category'] ?? 'N/A';

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 245, 184, 93), // Light yellow color
                          const Color.fromARGB(255, 233, 211, 88), // Darker yellow color
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Icon
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color.fromARGB(255, 80, 49, 2),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Name
                          _buildProfileTextField("Name:", name),
                          SizedBox(height: 20),

                          // Email
                          _buildProfileTextField("Email:", email),
                          SizedBox(height: 20),

                          // Card Number with stars
                          _buildProfileTextField("Card Number:", cardNumber),
                          SizedBox(height: 20),

                          // Mobile Number
                          _buildProfileTextField("Mobile Number:", mobileNumber),
                          SizedBox(height: 20),

                          // Owner Name
                          _buildProfileTextField("Card Owner:", ownerName),
                          SizedBox(height: 20),

                          // Category
                          _buildProfileTextField("Category:", category),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  // Custom method to create non-editable profile text fields
  Widget _buildProfileTextField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          enabled: false, // Make the field non-editable
          style: TextStyle(fontSize: 18, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter $title',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 2, color: const Color.fromARGB(255, 81, 50, 12)),
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: const Color.fromARGB(255, 225, 157, 68),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
