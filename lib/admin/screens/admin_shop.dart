import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    setState(() {
      _isEditing = true;
      _shopIdToEdit = shop.id;
      _isPasswordVisible = false;  // Default to password hidden on edit
    });
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
        child: Form(
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show all shops in the system
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Shop List'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Shop Owner').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching data'));
                      }

                      final shops = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          final shop = shops[index];
                          return ListTile(
                            title: Text(shop['store_name']),
                            subtitle: Text(shop['name']),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _loadShopData(shop),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.view_list),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
