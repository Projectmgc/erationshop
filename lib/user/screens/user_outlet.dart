import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class UserOutlet extends StatefulWidget {
  @override
  _UserOutletState createState() => _UserOutletState();
}

class _UserOutletState extends State<UserOutlet> {
  List<Map<String, dynamic>> allOutlets = [];
  List<Map<String, dynamic>> filteredOutlets = [];
  TextEditingController searchController = TextEditingController();
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to fetch current location
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
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
        title: Text('Outlet Details',style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              const Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) => _filterOutlets(query),
                decoration: InputDecoration(
                  labelText: 'Search by Store Name, Owner, or Address',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Shop Owner')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No outlets found'));
                  }

                  List<Map<String, dynamic>> outlets = [];
                  for (var doc in snapshot.data!.docs) {
                    final shopOwnerData = doc.data() as Map<String, dynamic>;
                    print(shopOwnerData['lat']);
                    outlets.add({
                      'outletName': shopOwnerData['store_name'] ?? 'N/A',
                      'ownerName': shopOwnerData['name'] ?? 'N/A',
                      'address': shopOwnerData['address'] ?? 'N/A',
                      'phone': shopOwnerData['phone'] ?? 'N/A',
                      'latitude': shopOwnerData['lat'],
                      'longitude': shopOwnerData['long'],
                      'stock': shopOwnerData['stock'] ?? [],
                    });
                  }

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
      color: const Color.fromARGB(255, 182, 177, 177).withOpacity(0.8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openMap(outlet['latitude'].toString(),
                      outlet['longitude'].toString()),
                  icon: Icon(Icons.location_on),
                  label: Text('View Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 169, 236, 173),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openRoute(outlet['latitude'].toString(),
                      outlet['longitude'].toString()),
                  icon: Icon(Icons.directions),
                  label: Text('Get Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 169, 236, 173),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openMap(String? latitude, String? longitude) async {
    if (latitude != null && longitude != null) {
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available')),
      );
    }
  }

  void _openRoute(String? latitude, String? longitude) async {
    if (latitude != null && longitude != null && currentPosition != null) {
      final routeUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${currentPosition!.latitude},${currentPosition!.longitude}&destination=$latitude,$longitude';
      if (await canLaunch(routeUrl)) {
        await launch(routeUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open route in Google Maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route or current location not available')),
      );
    }
  }
}
