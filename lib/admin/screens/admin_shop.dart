import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';

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
  final TextEditingController _passwordController = TextEditingController();  // New controller for password

  bool _isEditing = false;
  String? _shopIdToEdit;
  bool _isPasswordVisible = false;  // Boolean variable to control password visibility
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default to San Francisco
  Set<Marker> _markers = {};

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
          'password': _passwordController.text,  // Save the password field
          'location': GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude), // Save location
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
          'password': _passwordController.text,  // Update the password field
          'location': GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude), // Update location
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
    _passwordController.clear();  // Clear password field
    setState(() {
      _isEditing = false;
      _shopIdToEdit = null;
      _isPasswordVisible = false;  // Reset password visibility
      _selectedLocation = LatLng(37.7749, -122.4194); // Reset to default location
      _markers.clear();
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
    _passwordController.text = shop['password'] ?? '';  // Load password field

    if (shop['location'] != null) {
      GeoPoint location = shop['location'];
      _selectedLocation = LatLng(location.latitude, location.longitude);
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: _selectedLocation,
        infoWindow: InfoWindow(title: 'Selected Location'),
      ));
    }

    setState(() {
      _isEditing = true;
      _shopIdToEdit = shop.id;
      _isPasswordVisible = false;  // Default to password hidden on edit
    });
  }

  // Function to handle map taps and place a marker
  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;

      // Clear the existing markers and add a new marker
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: position,
        infoWindow: InfoWindow(title: 'Selected Location'),
      ));
    });

    // Move camera to the tapped location
    mapController.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Shop' : 'Add Shop'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
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
                    obscureText: !_isPasswordVisible,  // Toggle visibility
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
                            _isPasswordVisible = !_isPasswordVisible;  // Toggle password visibility
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
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text(_isEditing ? 'Update Shop' : 'Add Shop'),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      var address;




                      Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MapLocationPicker(
                        apiKey: 'AIzaSyCzu6eo_x-We7qK2SIKlkRy5EvJhnfSGv4',
                        popOnNextButtonTaped: true,
                        currentLatLng: const LatLng(29.146727, 76.464895),
                        debounceDuration: const Duration(milliseconds: 500),
                        onNext: (GeocodingResult? result) {
                          if (result != null) {
                            setState(() {
                              address = result.formattedAddress ?? "";
                            });
                          }
                        },
                        onSuggestionSelected: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            setState(() {
                              
                            });
                          }
                        },
                      );
                    },
                  ),
                );

                      

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text(_isEditing ? 'Update Shop' : 'Add Shop'),
                  ),
                ],
              ),
            ),


            
            // const SizedBox(height: 20),
            // // Google Maps Widget to select location
            // SizedBox(
            //   height: 300,
            //   child: GoogleMap(
            //     initialCameraPosition: CameraPosition(
            //       target: _selectedLocation,
            //       zoom: 14.0,
            //     ),
            //     onMapCreated: (GoogleMapController controller) {
            //       mapController = controller;
            //     },
            //     onTap: _onMapTapped, // Handle tap to select location
            //     markers: _markers, // Show the selected marker
            //   ),
            // ),
          
          
          
          ],
        ),
      ),
    );
  }}
