import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class AdminShopPage extends StatefulWidget {
  const AdminShopPage({super.key});

  @override
  State<AdminShopPage> createState() => _AdminShopPageState();
}

class _AdminShopPageState extends State<AdminShopPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEditing = false;
  String? _shopIdToEdit;
  bool _isPasswordVisible = false;
  late double _latitude;
  late double _longitude;

  // Function to add a new shop
  Future<void> _addShop() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newShop = {
          'name': _nameController.text,
          'store_name': _storeNameController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'shop_id': _shopIdController.text,
          'password': _passwordController.text,
          'lat': _latitude,
          'long': _longitude
        };

        await FirebaseFirestore.instance.collection('Shop Owner').add(newShop);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop added successfully')),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add shop')),
        );
      }
    }
  }

  // Function to update an existing shop
  Future<void> _updateShop() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updatedShop = {
          'name': _nameController.text,
          'store_name': _storeNameController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'shop_id': _shopIdController.text,
          'password': _passwordController.text,
          'location': GeoPoint(_latitude, _longitude),
        };

        await FirebaseFirestore.instance
            .collection('Shop Owner')
            .doc(_shopIdToEdit)
            .update(updatedShop);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop updated successfully')),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update shop')),
        );
      }
    }
  }

  // Function to clear the form fields
  void _clearForm() {
    _nameController.clear();
    _storeNameController.clear();
    _addressController.clear();
    _emailController.clear();
    _phoneController.clear();
    _shopIdController.clear();
    _passwordController.clear();
    setState(() {
      _isEditing = false;
      _shopIdToEdit = null;
      _isPasswordVisible = false;
      _latitude = 0.0;
      _longitude = 0.0;
    });
  }

  // Function to load data for editing
  void _loadShopData(DocumentSnapshot shop) {
    _nameController.text = shop['name'];
    _storeNameController.text = shop['store_name'];
    _addressController.text = shop['address'];
    _emailController.text = shop['email'];
    _phoneController.text = shop['phone'];
    _shopIdController.text = shop['shop_id'];
    _passwordController.text = shop['password'] ?? '';

    setState(() {
      _isEditing = true;
      _shopIdToEdit = shop.id;
      _isPasswordVisible = false;
    });
  }

  // Function to handle geocoding (search address and get latitude and longitude)
  Future<void> _getLatLongFromAddress() async {
    try {
      if (_addressController.text.isNotEmpty) {
        List<Location> locations = await locationFromAddress(_addressController.text);
        if (locations.isNotEmpty) {
          setState(() {
            _latitude = locations.first.latitude;
            _longitude = locations.first.longitude;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address converted to coordinates')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No location found for the address')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete the address field')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error in geocoding address')),
      );
    }
  }

  // Function to remove a shop
  Future<void> _removeShop(String shopId) async {
    try {
      await FirebaseFirestore.instance.collection('Shop Owner').doc(shopId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove shop')),
      );
    }
  }

  // Function to fetch the ShopOwner document ID based on shop_id
  Future<String?> _getShopOwnerDocId(String shopId) async {
    try {
      var shopOwnerQuerySnapshot = await FirebaseFirestore.instance
          .collection('Shop Owner')
          .where('shop_id', isEqualTo: shopId)
          .limit(1)
          .get();

      if (shopOwnerQuerySnapshot.docs.isNotEmpty) {
        return shopOwnerQuerySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Error fetching ShopOwner document ID: $e');
    }
    return null;
  }

  // Function to fetch ratings for the shop from the ShopRating collection
  Future<double> _getShopRatings(String shopId) async {
    try {
      // Fetch the ShopOwner document ID first using the shop_id
      String? shopOwnerDocId = await _getShopOwnerDocId(shopId);

      if (shopOwnerDocId != null) {
        // Use the ShopOwner document ID to fetch ratings from ShopRating collection
        var shopRatingDoc = await FirebaseFirestore.instance
            .collection('ShopRating')
            .doc(shopOwnerDocId)
            .get();

        if (shopRatingDoc.exists) {
          // Get the average rating from the ShopRating document
          return shopRatingDoc['averageRating'] ?? 0.0;
        }
      }
    } catch (e) {
      print('Error fetching shop ratings: $e');
    }
    return 0.0; // Return 0 if no ratings found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Shop' : 'Add Shop', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Shop Owner Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the shop owner name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _storeNameController,
                        decoration: const InputDecoration(labelText: 'Store Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the store name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the address';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: _getLatLongFromAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 208, 207, 206),
                        ),
                        child: const Text('Get Latitude & Longitude', style: TextStyle(color: Colors.black)),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _shopIdController,
                        decoration: const InputDecoration(labelText: 'Shop ID'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the shop ID';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isEditing ? _updateShop : _addShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 208, 207, 206),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: Text(_isEditing ? 'Update Shop' : 'Add Shop', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Manage Shops',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Shop Owner')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text('No shops available');
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var shop = snapshot.data!.docs[index];

                              return FutureBuilder<double>(
                                future: _getShopRatings(shop['shop_id']),
                                builder: (context, ratingSnapshot) {
                                  if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                    return ListTile(
                                      title: Text(shop['name']),
                                      subtitle: Text('Loading rating...'),
                                    );
                                  }

                                  double averageRating = ratingSnapshot.data ?? 0.0;
                                  // Determine the color based on the rating value
                                  Color ratingColor = averageRating < 3 ? Colors.red : const Color.fromARGB(255, 21, 159, 25);

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text(shop['name']),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Store: ${shop['store_name']}'),
                                          Text('Shop ID: ${shop['shop_id']}'),
                                          Text('Address: ${shop['address']}'),
                                          Text('Phone: ${shop['phone']}'),
                                          Text('Email: ${shop['email']}'),
                                          Text(
                                            'Average Rating: ${averageRating.toStringAsFixed(1)}',
                                            style: TextStyle(color: ratingColor),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _loadShopData(shop),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _removeShop(shop.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
