import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;

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
  File? _imageFile;
  final picker = ImagePicker();
  bool _isEditing = false;
  String? _shopIdToEdit;
  bool _isPasswordVisible = false;
  late double _latitude;
  late double _longitude;

  // Method to pick image using camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFacePlusPlus() async {
    try {
      if (_imageFile == null) {
        throw Exception('No image file selected.');
      }

      // Load image and resize it efficiently
      img.Image image = img.decodeImage(_imageFile!.readAsBytesSync())!;
      img.Image resizedImage = img.copyResize(image, width: 800); // Resize to 800px width to maintain detail

      // Compress image slightly for faster upload while maintaining detail
      final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85); // quality=85 for good quality and fast upload

      // Save resized and compressed image to a temporary file
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/resized_image.jpg');
      await tempFile.writeAsBytes(compressedImageBytes);

      var uri = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect');
      var request = http.MultipartRequest('POST', uri);
      request.fields['api_key'] = 'iQmi-6CZt09JXAkCEU-o1mEDbjgcSPUt'; // Replace with your API Key
      request.fields['api_secret'] = 'kQHG1Uu7gbCuledKsGSFDgzUrj4BzpjV'; // Replace with your API Secret
      request.files.add(await http.MultipartFile.fromPath('image_file', tempFile.path));

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var responseData = json.decode(responseBody.body);

        if (responseData['faces'] != null && responseData['faces'].isNotEmpty) {
          var faceToken = responseData['faces'][0]['face_token'];
          return faceToken;
        } else {
          throw Exception('No face detected in the image.');
        }
      } else {
        var responseData = json.decode(responseBody.body);
        var errorMessage = responseData['error_message'] ?? 'Unknown error';
        throw Exception('Face++ API error: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error with Face++ API: $e');
    }
  }

  // Function to add a new shop
  Future<void> _addShop() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String faceToken = '';
        if (_imageFile != null) {
          // Upload face image to Face++ and get face_token
          faceToken = await _uploadImageToFacePlusPlus();
        }

        final newShop = {
          'name': _nameController.text,
          'store_name': _storeNameController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'shop_id': _shopIdController.text,
          'password': _passwordController.text,
          'lat': _latitude,
          'long': _longitude,
          'face_token': faceToken,
        };

        await FirebaseFirestore.instance.collection('Shop Owner').add(newShop);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop added successfully')),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add shop , Check your selected Image for Face')),
        );
      }
    }
  }

  // Function to update an existing shop
  Future<void> _updateShop() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String faceToken = '';
        if (_imageFile != null) {
          // Upload face image to Face++ and get face_token
          faceToken = await _uploadImageToFacePlusPlus();
        }

        final updatedShop = {
          'name': _nameController.text,
          'store_name': _storeNameController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'shop_id': _shopIdController.text,
          'password': _passwordController.text,
          'location': GeoPoint(_latitude, _longitude),
          'face_token': faceToken,
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
          const SnackBar(content: Text('Failed to update shop ,  Check your selected Image for Face')),
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
      _imageFile = null;
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
      _imageFile = null; // Add logic to load the existing image file if needed
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
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 208, 207, 206),
                        ),
                        child: const Text('Capture Face Image', style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(height: 20),
                      _imageFile == null
                          ? const Text('No image selected.')
                          : Image.file(_imageFile!, width: 100, height: 100),
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

                              return ListTile(
                                title: Text(shop['name']),
                                subtitle: Text('Store: ${shop['store_name']}'),
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
}
