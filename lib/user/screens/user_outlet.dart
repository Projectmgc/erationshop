import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserOutlet extends StatefulWidget {
  @override
  _UserOutletState createState() => _UserOutletState();
}

class _UserOutletState extends State<UserOutlet> {
  List<Map<String, dynamic>> allOutlets = [];
  List<Map<String, dynamic>> filteredOutlets = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Function to filter outlets based on the search query
  void _filterOutlets(String query) {
    final filtered = allOutlets.where((outlet) {
      final outletName = outlet['outletName'].toLowerCase();
      final ownerName = outlet['ownerName'].toLowerCase();
      final address = outlet['address'].toLowerCase();
      return outletName.contains(query.toLowerCase()) ||
          ownerName.contains(query.toLowerCase()) ||
          address.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredOutlets = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outlet Details'),
        backgroundColor: Color.fromARGB(255, 245, 184, 93),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity, // Ensure the container takes up the full screen width
        height: double.infinity, // Ensure the container takes up the full screen height
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
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  _filterOutlets(query); // Call filter function when user types
                },
                decoration: InputDecoration(
                  labelText: 'Search by Store Name, Owner, or Address',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            // StreamBuilder to fetch and display data from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Shop Owner')
                    .snapshots(),
                builder: (context, snapshot) {
                  // Show loading indicator while waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Handle error scenario
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Handle no data found scenario
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No outlets found'));
                  }

                  // Extract outlet details directly from Firestore documents
                  List<Map<String, dynamic>> outlets = [];
                  for (var doc in snapshot.data!.docs) {
                    final shopOwnerData = doc.data() as Map<String, dynamic>;

                    final outletName = shopOwnerData['store_name'] ?? 'N/A';
                    final ownerName = shopOwnerData['name'] ?? 'N/A';
                    final address = shopOwnerData['address'] ?? 'N/A';
                    final phone = shopOwnerData['phone'] ?? 'N/A';
                    final stock = shopOwnerData['stock'] ?? [];

                    // Add the outlet data to the list
                    outlets.add({
                      'outletName': outletName,
                      'ownerName': ownerName,
                      'address': address,
                      'phone': phone,
                      'stock': stock,
                    });
                  }

                  // Save all outlets and initially display all
                  allOutlets = outlets;
                  filteredOutlets = allOutlets;

                  return ListView.builder(
                    itemCount: filteredOutlets.length,
                    itemBuilder: (context, index) {
                      return _buildOutletCard(filteredOutlets[index]);
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

  Widget _buildOutletCard(Map<String, dynamic> outlet) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              outlet['outletName'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Owner: ${outlet['ownerName']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Address: ${outlet['address']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: ${outlet['phone']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Stock Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                for (var item in outlet['stock']) _buildStockItemCard(item),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItemCard(Map<String, dynamic> item) {
    return Card(
      color: Colors.orange[50],
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  item['image'] ?? 'asset/rawrice.jpeg', // Ensure an image path is provided
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item'] ?? 'Item Name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Quantity: ${item['quantity']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Price: \$${item['price']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
