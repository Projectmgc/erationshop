import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _mobileNoController = TextEditingController();

  int membersCount = 0;
  List<TextEditingController> _memberNameControllers = [];

  // List to hold card data
  List<Map<String, dynamic>> _cardDetailsList = [];

  bool _isLoading = true; // Flag for loading state

  // Fetch all cards from Firebase Firestore
  Future<void> _fetchAllCards() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Card').get();

      final cards = snapshot.docs.map((doc) {
        return {
          'owner_name': doc['owner_name'] ?? 'Unknown',
          'card_no': doc['card_no'] ?? 'Unknown',
          'category': doc['category'] ?? 'Unknown',
          'mobile_no': doc['mobile_no'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        _cardDetailsList = cards;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching card details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch cards')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCategoryIdFromCategoryName(String categoryName) {
    if (categoryName == 'apl') {
      return ("mZEnrh5atrnyd9xIwTjl");
    } else {
      return ("HIx8l048XyfjFZ4VL2gU");
    }
  }

  // Function to add a new card to Firestore
  Future<void> _addCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String categoryId = _getCategoryIdFromCategoryName(_categoryController.text);

        // Capture the current date and subtract 31 days
        DateTime now = DateTime.now();
        DateTime lastPurchaseDateTime = now.subtract(Duration(days: 31));

        // Convert DateTime to Timestamp
        Timestamp lastPurchaseDate = Timestamp.fromDate(lastPurchaseDateTime);

        await FirebaseFirestore.instance.collection('Card').add({
          'owner_name': _ownerNameController.text,
          'card_no': _cardNoController.text,
          'category': _categoryController.text,
          'members_count': membersCount.toString(),
          'mobile_no': _mobileNoController.text,
          'member_list': List.generate(membersCount, (index) => _memberNameControllers[index].text),
          'category_id': categoryId,
          'last_purchase_date': lastPurchaseDate, // Add the last purchase date as Timestamp
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );

        _ownerNameController.clear();
        _cardNoController.clear();
        _categoryController.clear();
        _mobileNoController.clear();

        setState(() {
          membersCount = 0;
          _memberNameControllers.clear();
        });

        _fetchAllCards();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add card')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAllCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              const Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Cards Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Loading indicator or Card Details
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _cardDetailsList.isEmpty
                        ? const Center(child: Text('No cards found'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _cardDetailsList.length,
                            itemBuilder: (context, index) {
                              final card = _cardDetailsList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Card Number: ${card['card_no']}'),
                                      Text('Owner Name: ${card['owner_name']}'),
                                      Text('Category: ${card['category']}'),
                                      Text('Mobile Number: ${card['mobile_no']}'),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                const SizedBox(height: 30),

                // New Card Form (Boxy Structure)
                const Text(
                  'Enter New Card Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Add New Card Form inside Boxy Container
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: const Color.fromARGB(255, 201, 199, 199),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(66, 0, 0, 0),
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        // Category
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(labelText: 'Category'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the category';
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
                          decoration: const InputDecoration(labelText: 'Number of Family Members'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              membersCount = int.tryParse(value) ?? 0;
                              _memberNameControllers = List.generate(membersCount, (index) => TextEditingController());
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
                        const SizedBox(height: 20),

                        // Members' Details (Scrollable List)
                        SingleChildScrollView(
                          child: Column(
                            children: List.generate(membersCount, (index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Family Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _memberNameControllers[index],
                                    decoration: InputDecoration(labelText: 'Member ${index + 1} Name'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the member name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addCard,
                          child: const Text('   Add Card   ',style: TextStyle(color: Colors.black),),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                        ),
                      ],
                    ),
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
