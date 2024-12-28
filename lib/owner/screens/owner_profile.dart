import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required String shopId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String shopId = '';
  Map<String, dynamic>? ownerData;

  @override
  void initState() {
    super.initState();
    _getShopId();
  }

  // Retrieve shop_id from SharedPreferences
  void _getShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shopId = prefs.getString('shop_id') ?? '';
    });

    if (shopId.isNotEmpty) {
      _fetchOwnerData(shopId);
    }
  }

  // Fetch owner data from Firestore using the shop_id
  void _fetchOwnerData(String shopId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Shop Owner')
          .where('shop_id', isEqualTo: shopId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          ownerData = querySnapshot.docs.first.data();
        });
      }
    } catch (e) {
      print('Error fetching owner data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ownerData == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 245, 184, 93),
                    const Color.fromARGB(255, 233, 211, 88),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Icon in the center
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurpleAccent,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Displaying profile data in a box format
                    _buildInfoBox('Name', ownerData!['name']),
                    _buildInfoBox('Email', ownerData!['email']),
                    _buildInfoBox('Phone', ownerData!['phone']),
                    _buildInfoBox('Shop', ownerData!['store_name']),
                    _buildInfoBox('Address', ownerData!['address']),
                  ],
                ),
              ),
            ),
    );
  }

  // Method to build a single info box for profile data
  Widget _buildInfoBox(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title:',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black87,
                 // Ensures long text doesn't overflow
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
