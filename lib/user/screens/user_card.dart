import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erationshop/admin/screens/admin_product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Map<String, dynamic>? cardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCardData();
  }

  Future<void> _loadCardData() async {
    final prefs = await SharedPreferences.getInstance();
    final cardNo = prefs.getString('card_no');

    if (cardNo != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('Card')
            .where('card_no', isEqualTo: cardNo)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            cardData = snapshot.docs.first.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Card not found for card number: $cardNo');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching card data: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('Card number not found in shared preferences.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ration Card Details'),
        flexibleSpace: const BackgroundGradient(),
      ),
      // Apply the background gradient to the entire body to cover the full screen
      body: Container(
        width: double.infinity,
        height: double.infinity,  // Ensure the container takes up the full screen
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cardData != null
                ? _buildCardDetails(context)
                : const Center(
                    child: Text('No card data found.'),
                  ),
      ),
    );
  }

  Widget _buildCardDetails(BuildContext context) {
    return SingleChildScrollView(  // Added to handle overflow when content is too long
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardDetailRow('Card Number:', cardData!['card_no'] ?? "N/A"),
                _buildCardDetailRow('Owner Name:', cardData!['owner_name'] ?? "N/A"),
                _buildCardDetailRow('Category:', cardData!['category'] ?? "N/A"),
                _buildCardDetailRow('Members Count:', cardData!['members_count'] ?? "N/A"),
                _buildCardDetailRow('Mobile Number:', cardData!['mobile_no'] ?? "N/A"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
