import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ration Cards'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to AddCardPage when the "Add" button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCardPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Card').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          final rationCards = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: rationCards.length,
            itemBuilder: (context, index) {
              final card = rationCards[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.deepPurpleAccent),
                  title: Text(card['owner_name']),
                  subtitle: Text('Card Number: ${card['card_no']}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailsPage(
                          card: card,
                          onRemoveCard: () {
                            FirebaseFirestore.instance.collection('Card').doc(card.id).delete();
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class CardDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot card;
  final VoidCallback onRemoveCard;

  const CardDetailsPage({required this.card, required this.onRemoveCard, super.key});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  late Future<List<Map<String, dynamic>>> _membersListFuture;

  @override
  void initState() {
    super.initState();
    _membersListFuture = _getMembers();
  }

  // Fetch members from the subcollection
  Future<List<Map<String, dynamic>>> _getMembers() async {
    final membersSnapshot = await widget.card.reference.collection('member_list').get();
    return membersSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    var card = widget.card;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  
        future: _membersListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching members'));
          }

          final members = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Card Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.deepPurpleAccent,
                      child: IconButton(
                        icon: const Icon(Icons.person, color: Colors.white, size: 30),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add or change profile picture.')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cardholder: ${card['owner_name']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Card Number: ${card['card_no']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          // Display category
                          Text(
                            'Category: ${card['category']}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Family Members',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurpleAccent,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('Member ${index + 1}: ${members[index]['member_name']}'),
                        subtitle: Text('ID: ${members[index]['mobile_no']}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onRemoveCard();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Remove Card'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _cardNoController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _membersCountController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();

  int membersCount = 0;
  List<TextEditingController> _memberNameControllers = [];
  List<TextEditingController> _memberPhoneControllers = [];

  // Cloudinary config
  final Cloudinary _cloudinary = Cloudinary.signedConfig(
    cloudName: 'dfoid6qev', // Replace with your Cloudinary cloud name
    apiKey: '948219642975793', // Replace with your Cloudinary API key
    apiSecret: 'Zzea0hJAlegwGmiGVRBKK8inbOs', // Replace with your Cloudinary API secret
  );

  String? _profileImageUrl; // URL to store the uploaded profile picture

  // List to hold category data from Firebase
  List<String> _categories = [];
  String? _selectedCategory;
  String? _selectedCategoryId; // Variable to store the selected category's document ID

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories from Firestore on page load
  }

  // Fetch categories from Firebase Firestore
  Future<void> _fetchCategories() async {
    try {
      // Query the "Category" collection to get category names and their document IDs
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Category').get();
      final categories = snapshot.docs.map((doc) => doc['category_name'] as String).toList();
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories[0];  // Set the first category as default
          _categoryController.text = _selectedCategory!;
        }
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  // Fetch the selected category's document ID
  Future<void> _getCategoryId(String categoryName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Category')
          .where('category_name', isEqualTo: categoryName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Set the selected category's document ID
        _selectedCategoryId = snapshot.docs[0].id;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch category ID')),
      );
    }
  }

  // Function to select profile image and upload to Cloudinary
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    // Pick an image
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageUrl=File(pickedFile.path) as String?;
      });
      try {
        // Upload the image to Cloudinary
        final CloudinaryResponse response = await _cloudinary.upload(
          file:pickedFile.path, 
          folder: 'profile_pictures', // Cloudinary folder
        );

        // If the upload is successful, get the URL
        if (response.isSuccessful) {
          setState(() {
            _profileImageUrl = response.secureUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading image')),
        );
      }
    }
  }

  // Function to submit form data and add card to Firestore
  Future<void> _addCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Fetch the category document ID based on the selected category
        await _getCategoryId(_selectedCategory!);

        // Check if the category ID was successfully retrieved
        if (_selectedCategoryId != null) {
          // Create a new Card document in Firestore
          DocumentReference cardRef = await FirebaseFirestore.instance.collection('Card').add({
            'owner_name': _ownerNameController.text,
            'card_no': _cardNoController.text,
            'category': _selectedCategory, // Use the selected category name
            'category_id': _selectedCategoryId, // Store the category document ID
            'members_count': membersCount.toString(),
            'mobile_no': _mobileNoController.text,
            'profile_picture_url': _profileImageUrl, // Store the profile image URL
          });

          // Add members to the 'member_list' subcollection for this card
          for (int i = 0; i < membersCount; i++) {
            await cardRef.collection('member_list').doc('member${i + 1}').set({
              'member_name': _memberNameControllers[i].text,
              'mobile_no': _memberPhoneControllers[i].text,
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category ID not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add card')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Card Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Cardholder Name
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Cardholder Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cardholder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Card Number
              TextFormField(
                controller: _cardNoController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _categoryController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Mobile Number
              TextFormField(
                controller: _mobileNoController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Number of Family Members
              TextFormField(
                controller: _membersCountController,
                decoration: const InputDecoration(labelText: 'Number of Family Members'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    membersCount = int.tryParse(value) ?? 0;
                    _memberNameControllers = List.generate(membersCount, (index) => TextEditingController());
                    _memberPhoneControllers = List.generate(membersCount, (index) => TextEditingController());
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of members';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Add Members',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Add member fields based on members count
              for (int i = 0; i < membersCount; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _memberNameControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Member ${i + 1} Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name for member ${i + 1}';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _memberPhoneControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Member ${i + 1} Mobile Number',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number for member ${i + 1}';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Image Upload Button
              ElevatedButton(
                onPressed: _pickAndUploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Upload Profile Picture'),
              ),
              const SizedBox(height: 20),
              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Add Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}