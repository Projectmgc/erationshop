import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserOutlet extends StatefulWidget {
  @override
  _UserOutletState createState() => _UserOutletState();
}

class _UserOutletState extends State<UserOutlet> {
  List<Map<String, dynamic>> allOutlets = [];
  List<Map<String, dynamic>> filteredOutlets = [];
  TextEditingController searchController = TextEditingController();
  Position? currentPosition;
  String? cardNumber;

  Map<String, double> outletRatings = {}; // To hold ratings for each shop
  bool isDataFetched = false;
  bool isUserRatingFetched = false;

  @override
  void initState() {
    super.initState();
    _getCardNumberFromPreferences();
    _getCurrentLocation();
  }

  // Fetch card number from SharedPreferences
  Future<void> _getCardNumberFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cardNumber = prefs.getString('card_no');
    });
  }

  // Fetch current location
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

  // Submit the rating
  Future<void> _submitRating(String shopId, double rating) async {
    try {
      if (cardNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login first')),
        );
        return;
      }

      if (shopId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shop not found')),
        );
        return;
      }

      // Fetch the shop ratings from Firestore
      DocumentSnapshot shopRatingSnapshot =
          await FirebaseFirestore.instance.collection('ShopRating').doc(shopId).get();

      List<dynamic> ratings = [];

      if (shopRatingSnapshot.exists) {
        ratings = shopRatingSnapshot['ratings'] ?? [];
        bool isRatedByUser = false;

        // Check if the user has already rated this shop
        for (int i = 0; i < ratings.length; i++) {
          if (ratings[i]['cardNumber'] == cardNumber) {
            // If the user has already rated, replace the rating
            ratings[i]['rating'] = rating;
            isRatedByUser = true;
            break;
          }
        }

        if (!isRatedByUser) {
          // If not rated by this user, add their rating
          ratings.add({
            'cardNumber': cardNumber,
            'rating': rating,
          });
        }
      } else {
        // If no ratings exist, create a new list of ratings
        ratings.add({
          'cardNumber': cardNumber,
          'rating': rating,
        });
      }

      // Recalculate the average rating
      double averageRating = await _calculateAverageRating(ratings);

      await FirebaseFirestore.instance.collection('ShopRating').doc(shopId).set({
        'ratings': ratings,
        'averageRating': averageRating, // Ensure this function returns a double
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted!')),
      );
      setState(() {}); // Refresh UI to reflect updated ratings
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  // Calculate average rating from the list of ratings
  Future<double> _calculateAverageRating(List<dynamic> ratings) async {
    double totalRating = 0.0;
    int count = 0;

    // Sum up all the ratings
    for (var rating in ratings) {
      totalRating += (rating['rating'] as double); // Ensure it's treated as double
      count++;
    }

    return count > 0 ? totalRating / count : 0.0; // Return as a double
  }

  // Fetch the rating for a specific shop and user
  Future<void> _fetchUserRating(String shopId) async {
    if (cardNumber == null || isUserRatingFetched) return; // No need to proceed if no card number or already fetched

    try {
      DocumentSnapshot shopRatingSnapshot =
          await FirebaseFirestore.instance.collection('ShopRating').doc(shopId).get();

      if (shopRatingSnapshot.exists) {
        List<dynamic> ratings = shopRatingSnapshot['ratings'] ?? [];

        // Find the user's rating
        for (var rating in ratings) {
          if (rating['cardNumber'] == cardNumber) {
            setState(() {
              outletRatings[shopId] = rating['rating'].toDouble();
            });
            break; // Stop once we find the user's rating
          }
        }
      }
      // Flag to indicate that the user's rating has been fetched for the shop
      setState(() {
        isUserRatingFetched = true;
      });
    } catch (e) {
      print('Error fetching user rating: $e');
    }
  }

  // Filter outlets based on search query
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
      title: Text('Outlet Details', style: TextStyle(color: Colors.white)),
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
            child: isDataFetched
                ? ListView.builder(
                    itemCount: filteredOutlets.length,
                    itemBuilder: (context, index) {
                      return _buildOutletCard(filteredOutlets[index]);
                    },
                  )
                : FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('Shop Owner').get(),
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
                        outlets.add({
                          'outletName': shopOwnerData['store_name'] ?? 'N/A',
                          'ownerName': shopOwnerData['name'] ?? 'N/A',
                          'address': shopOwnerData['address'] ?? 'N/A',
                          'phone': shopOwnerData['phone'] ?? 'N/A',
                          'latitude': shopOwnerData['lat'],
                          'longitude': shopOwnerData['long'],
                          'stock': shopOwnerData['stock'] ?? [],
                          'shopId': doc.id, // The shop's document ID
                        });
                      }

                      // Using addPostFrameCallback to ensure the state update happens after build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          allOutlets = outlets;
                          filteredOutlets = allOutlets;
                          isDataFetched = true;
                        });
                      });

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
    String shopId = outlet['shopId'];
    // Fetch the last submitted rating or the default rating
    double localRating = outletRatings[shopId] ?? 0.0;

    // Fetch the user's rating when the widget is built (if not already fetched)
    _fetchUserRating(shopId);

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
            SizedBox(height: 10),
            FutureBuilder<double>(
              future: _getAverageRating(shopId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error fetching rating');
                } else {
                  double avgRating = snapshot.data ?? 0.0;
                  return Text('Average Rating: ${avgRating.toStringAsFixed(1)}');
                }
              },
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < localRating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    setState(() {
                      outletRatings[shopId] = (index + 1).toDouble(); // Store the rating
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(outlet['latitude'].toString(),
                        outlet['longitude'].toString()),
                    icon: Icon(Icons.location_on),
                    label: Text('View Location'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openRoute(outlet['latitude'].toString(),
                        outlet['longitude'].toString()),
                    icon: Icon(Icons.directions),
                    label: Text('Get Route'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitRating(shopId, localRating),
                    icon: Icon(Icons.rate_review),
                    label: Text('Submit Rating'),
                  ),
                ),
              ],
            ),
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

  // Fetch average rating from Firestore
  Future<double> _getAverageRating(String shopId) async {
    try {
      DocumentSnapshot shopRatingSnapshot = await FirebaseFirestore.instance
          .collection('ShopRating')
          .doc(shopId)
          .get();

      if (!shopRatingSnapshot.exists) {
        return 0.0; // Return 0.0 if the document does not exist
      }

      List<dynamic> ratings = shopRatingSnapshot['ratings'] ?? [];
      if (ratings.isEmpty) {
        return 0.0; // Return 0.0 if no ratings are available
      }

      double totalRating = 0.0;
      int count = 0;

      // Sum up all the ratings
      for (var rating in ratings) {
        totalRating += (rating['rating'] as double); // Ensure it's treated as double
        count++;
      }

      return count > 0 ? totalRating / count : 0.0; // Return as a double
    } catch (e) {
      print('Error fetching average rating: $e');
      return 0.0; // Return 0.0 in case of error
    }
  }
}
