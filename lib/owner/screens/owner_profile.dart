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
      body: Padding(
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
              
              // Name Section
              _buildProfileInfoRow("Name", "John Doe"),
              SizedBox(height: 20),
              
              // Store ID Section
              _buildProfileInfoRow("Store ID", "12345678"),
              SizedBox(height: 20),
              
              // Address Section
              _buildProfileInfoRow("Address", "1234 Market Street, City, Country"),
              SizedBox(height: 20),
              
              // Store Name Section
              _buildProfileInfoRow("Store Name", "Doe's Grocery Store"),
              SizedBox(height: 20),

              _buildProfileInfoRow("Phone", "1234567890"),
              SizedBox(height: 20),

              _buildProfileInfoRow("Email", "luiyrthiqy@gmail.com"),
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
      ),
    );
  }

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
