import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProduct extends StatefulWidget {
  const AdminProduct({super.key});

  @override
  _AdminProductState createState() => _AdminProductState();
}

class _AdminProductState extends State<AdminProduct> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Stream<QuerySnapshot> _categoryStream;
  Stream<QuerySnapshot>? _productCategoryStream;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageController = TextEditingController(); // Controller for image URL
  String _selectedCategory = 'bpl'; // Default category

  @override
  void initState() {
    super.initState();
    _categoryStream = _firestore.collection('Category').snapshots();
    _productCategoryStream = _firestore.collection('Product_Category').snapshots(); // Initialize the stream
  }

  // Function to remove a product from Product_Category collection
  Future<void> _removeProductFromProductCategory(String productId) async {
    try {
      await _firestore.collection('Product_Category').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed from Product_Category successfully')));

      // After removing the product from the 'Product_Category', 
      // remove its references from the 'Category' collection's product arrays
      await _removeProductFromCategoryArrays(productId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error removing product: $e')));
    }
  }

  // Function to remove product references from 'Category' product arrays
  Future<void> _removeProductFromCategoryArrays(String productId) async {
    try {
      QuerySnapshot categorySnapshot = await _firestore.collection('Category').get();
      for (var categoryDoc in categorySnapshot.docs) {
        List<dynamic> products = categoryDoc['product'];
        List<dynamic> updatedProducts = products.where((product) => product['product_id'] != productId).toList();

        await categoryDoc.reference.update({'product': updatedProducts});
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product references removed from Category successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error removing product references from Category : ')));
    }
  }

  // Function to add a product
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return; // Validate the form

    try {
      String name = _nameController.text;
      String image = _imageController.text.isEmpty || _imageController.text == null ? "na" : _imageController.text;
      String description = "na"; // Optional description field
      double price = double.tryParse(_priceController.text) ?? 0.0;
      int quantity = int.tryParse(_quantityController.text) ?? 0;

      // Step 1: Add the product to the 'Product_Category' collection
      var productRef = await _firestore.collection('Product_Category').add({
        'name': name,
        'description': description,
        'image': image,
      });

      // Step 2: Update the category's product array
      await _addProductToCategory(productRef.id, price, quantity);

      // Step 3: Clear the form fields
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _imageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Function to add the product to the selected category
  Future<void> _addProductToCategory(String productId, double price, int quantity) async {
    try {
      // Query the category document using the 'category_name' field
      var categoryQuerySnapshot = await _firestore
          .collection('Category')
          .where('category_name', isEqualTo: _selectedCategory) // Filter by category_name
          .get();

      if (categoryQuerySnapshot.docs.isNotEmpty) {
        // If the category exists, get the first matching document
        var categoryDoc = categoryQuerySnapshot.docs.first;
        
        // Add the product to the 'product' array in the category document
        await _firestore.collection('Category').doc(categoryDoc.id).update({
          'product': FieldValue.arrayUnion([ 
            {
              'product_id': productId, // Use the product document ID
              'price': price.toString(), // Store price as a string
              'quantity': quantity.toString(), // Store quantity as a string
            }
          ]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to the selected category'))
        );
      } else {
        // Handle the case where no category is found with that name
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category not found'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Manage Products'),
        flexibleSpace: const BackgroundGradient(),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Existing Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _productCategoryStream, // Use the stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final products = snapshot.data!.docs;

                  return Column(
                    children: products.map((productDoc) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading: productDoc['image'] != "na" ? Image.network(
                            productDoc['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ) : const SizedBox(height: 60, width: 60,), // Display product Image
                          title: Text(productDoc['name']), // Display product Name
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              // Call the new remove function
                              _removeProductFromProductCategory(productDoc.id);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40), // Add some space before the adding section

              const Text(
                'Add a New Product',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: _categoryStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        // Get the categories
                        final categories = snapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select Category'),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              items: categories.map((categoryDoc) {
                                return DropdownMenuItem<String>(
                                  value: categoryDoc['category_name'],
                                  child: Text(categoryDoc['category_name']),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text('Add Product'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
