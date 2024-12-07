import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          } else {
            final profile = snapshot.data?.data();
            final String name = profile?['name'] ?? 'N/A';
            final String aadharNumber = '1234 5678 9876'; // Placeholder for Aadhar number
            final String cardNumber = profile?['card_no'] ?? '**** **** ****'; // Placeholder for card number
            final String mobileNumber = '9876 3432 3232'; // Placeholder for mobile number

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

                    // Aadhar Number with last digits masked
                    _buildProfileTextField("Aadhar Number:", aadharNumber.replaceRange(0, 9, "**** ****")),
                    SizedBox(height: 20),

                    // Card Number with stars
                    _buildProfileTextField("Card Number:", cardNumber.replaceRange(4, 12, '**** ****')),
                    SizedBox(height: 20),

                    // Mobile Number with stars
                    _buildProfileTextField("Mobile Number:", mobileNumber.replaceRange(0, 8, '**** ****')),
                    SizedBox(height: 20),
                  ],
                ),
              ),
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
