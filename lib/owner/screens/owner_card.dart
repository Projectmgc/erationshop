import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final List<Map<String, String>> _members = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with the card registration logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card Registered Successfully!')),
      );
    }
  }

  void _addMember() {
    setState(() {
      _members.add({
        'name': '',   
        'uid': '',
      });
    });
  }

  void _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _photo = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Registration'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading Section
            Text(
              'Register New Card',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 20),

            // Card Registration Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Owner Name Field
                  _buildTextField(
                    controller: _ownerNameController,
                    label: 'Card Owner Name',
                    hint: 'Enter card owner name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the card owner name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Card Number Field
                  _buildTextField(
                    controller: _cardNumberController,
                    label: 'Card Number',
                    hint: 'Enter card number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a card number';
                      }
                      if (value.length != 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),

                  // Member List Section
                  Text(
                    'Member List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  for (int i = 0; i < _members.length; i++)
                    _buildMemberForm(i),
                  SizedBox(height: 20),

                  // Add Member Button
                  ElevatedButton(
                    onPressed: _addMember,
                    child: Text('Add Member'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Register Card',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildMemberForm(int index) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController uidController = TextEditingController();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: nameController,
                label: 'Member Name',
                hint: 'Enter member name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter member name';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: uidController,
                label: 'Member UID',
                hint: 'Enter member UID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter member UID';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
