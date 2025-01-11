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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageController = TextEditingController(); // Controller for image URL
  String _selectedCategory = 'bpl'; // Default category

  @override
  void initState() {
    super.initState();
    // Initialize the stream to fetch data from Category collection
    _categoryStream = _firestore.collection('Category').snapshots();
  }

  // Method to remove a specific product from the product array in Category document
  Future<void> _removeProduct(String categoryId, String productId) async {
    try {
      var categoryDoc = await _firestore.collection('Category').doc(categoryId).get();

      if (categoryDoc.exists) {
        List<dynamic> products = categoryDoc['product'];

        // Find the product map in the array with the matching product_id
        var productToRemove = products.firstWhere(
          (product) => product['product_id'] == productId,
          orElse: () => null,
        );

        // If the product is found, remove it from the array
        if (productToRemove != null) {
          await _firestore.collection('Category').doc(categoryId).update({
            'product': FieldValue.arrayRemove([productToRemove]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product removed successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product not found')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fetch product details using product_id
  Future<Map<String, dynamic>> _fetchProductDetails(String productId) async {
    try {
      var productDoc = await _firestore.collection('Product_Category').doc(productId).get();
      return productDoc.exists ? productDoc.data()! : {};
    } catch (e) {
      throw Exception("Error fetching product details");
    }
  }

  // Function to add a product
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return; // Validate the form

    try {
      String name = _nameController.text;
      String image = _imageController.text.isEmpty ? "na" : _imageController.text;
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Existing Category and Product Fetching/Removing Section ---
              const Text(
                'Manage Existing Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 20),

              // Display the list of categories and products
              StreamBuilder<QuerySnapshot>(
                stream: _categoryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Get categories
                  final categories = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.map((categoryDoc) {
                      String categoryId = categoryDoc.id;
                      List<dynamic> products = categoryDoc['product'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryDoc['category_name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Display products in this category
                          FutureBuilder<List<Widget>>(
                            future: _getProductWidgets(products, categoryId),
                            builder: (context, futureSnapshot) {
                              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (futureSnapshot.hasError) {
                                return Center(child: Text('Error: ${futureSnapshot.error}'));
                              }

                              // Return the list of widgets
                              return Column(
                                children: futureSnapshot.data!,
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40), // Add some space before the adding section

              // --- New Product Adding Section ---
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
                    // Image URL TextField
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
                      stream: _categoryStream, // Stream that fetches the categories from Firestore
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
                                  value: categoryDoc['category_name'], // Using category_name as the value
                                  child: Text(categoryDoc['category_name']), // Display the category name
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

  // Function to generate product widgets based on product array
  Future<List<Widget>> _getProductWidgets(List<dynamic> products, String categoryId) async {
    List<Widget> productWidgets = [];

    for (var product in products) {
      String productId = product['product_id'];

      // Fetch product details using product_id
      Map<String, dynamic> productDetails = await _fetchProductDetails(productId);

      if (productDetails.isNotEmpty) {
        String name = productDetails['name'];
        String image = productDetails['image'];

        // Parse price and quantity from string to double and int respectively
        double price = double.tryParse(product['price']) ?? 0.0;
        int quantity = int.tryParse(product['quantity']) ?? 0;

        productWidgets.add(
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Display product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16.0),

                  // Display product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Price: \₹${price.toStringAsFixed(2)}'), // Format price as a currency
                        Text('Quantity: $quantity'),
                      ],
                    ),
                  ),

                  // Remove button
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      _removeProduct(categoryId, productId);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return productWidgets;
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
