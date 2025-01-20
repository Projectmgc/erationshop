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
  final TextEditingController _passwordController = TextEditingController(); // New controller for password

  bool _isEditing = false;
  String? _shopIdToEdit;
  bool _isPasswordVisible = false; // Boolean variable to control password visibility
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
          'password': _passwordController.text, // Save the password field
          'lat': _latitude,
          'long': _longitude // Save location
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
          'password': _passwordController.text, // Update the password field
          'location': GeoPoint(_latitude, _longitude), // Update location
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
    _passwordController.clear(); // Clear password field
    setState(() {
      _isEditing = false;
      _shopIdToEdit = null;
      _isPasswordVisible = false; // Reset password visibility
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
    _passwordController.text = shop['password'] ?? ''; // Load password field

    if (shop['location'] != null) {
      GeoPoint location = shop['location'];
      _latitude = location.latitude;
      _longitude = location.longitude;
    }

    setState(() {
      _isEditing = true;
      _shopIdToEdit = shop.id;
      _isPasswordVisible = false; // Default to password hidden on edit
    });
  }

  // Function to handle geocoding (search address and get latitude and longitude)
  Future<void> _getLatLongFromAddress() async {
    try {
      // Perform geocoding to get the latitude and longitude from the address
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Shop' : 'Add Shop',style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity, // Ensure it fills the width
        height: double.infinity, // Ensure it takes up full height
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
        child: SingleChildScrollView( // This makes the body scrollable
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
                      // Button to trigger geocoding
                      ElevatedButton(
                        onPressed: _getLatLongFromAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 208, 207, 206),
                        ),
                        child: const Text('Get Latitude & Longitude',style: TextStyle(color: Colors.black),),
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
                        obscureText: !_isPasswordVisible, // Toggle visibility
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
                                _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
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
                        child: Text(_isEditing ? 'Update Shop' : 'Add Shop',style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),),
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
