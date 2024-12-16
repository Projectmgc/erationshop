import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Shop Owner')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Show loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          // Handle error scenario
          if (snapshot.hasError) {
            return Center(child: Text('Error :${snapshot.error}'));
          }
          
          // Handle no data found scenario
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          }
          
          // Extract profile data
          final profile = snapshot.data!.data() as Map<String, dynamic>;
          final String name = profile['name'] ?? 'N/A';
          final String shopId = profile['shop_id'] ?? '**** **** ****'; 
          final String email = profile['email'] ?? 'N/A'; 
          final String phone = profile['phone'] ?? 'N/A';
          final String address = profile['address'] ?? 'N/A';
          final String storeName = profile['store_name'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  Center(         
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('asset/profile_picture.jpg'), // Replace with your image path
                    ),
                  ),
                  SizedBox(height: 20),

                  // Profile information sections
                  _buildProfileInfoRow("Name", name),
                  SizedBox(height: 20),
                  _buildProfileInfoRow("Store ID", shopId),
                  SizedBox(height: 20),
                  _buildProfileInfoRow("Address", address),
                  SizedBox(height: 20),
                  _buildProfileInfoRow("Store Name", storeName),
                  SizedBox(height: 20),
                  _buildProfileInfoRow("Phone", phone),
                  SizedBox(height: 20),
                  _buildProfileInfoRow("Email", email),
                  SizedBox(height: 40),

                  // Edit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // You can add functionality to edit the profile here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.roboto(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build each profile info row
  Widget _buildProfileInfoRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
