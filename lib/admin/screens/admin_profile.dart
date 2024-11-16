import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Initial values
  String _name = 'John Doe';
  String _phone = '+1 234 567 890';
  String _email = 'johndoe@example.com';
  String _username = 'johndoe';

  // Editable flags
  bool _isEditing = false;

  // TextEditingControllers to manage input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current values
    _nameController.text = _name;
    _phoneController.text = _phone;
    _emailController.text = _email;
    _usernameController.text = _username;
  }

  @override
  void dispose() {
    // Dispose controllers when done
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Function to save the updated profile
  void _saveProfile() {
    setState(() {
      _name = _nameController.text;
      _phone = _phoneController.text;
      _email = _emailController.text;
      _username = _usernameController.text;
      _isEditing = false;
    });
  }

  // Function to enable editing mode
  void _editProfile() {
    setState(() {
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () {
                  // Placeholder for changing profile picture (could open image picker)
                  print('Profile picture tapped');
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile.jpg'), // Placeholder image
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Name
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            // Phone Number
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            // Email ID
            TextFormField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Email ID',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            // User Name
            TextFormField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Username',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            // Edit / Save Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit Button
                if (!_isEditing)
                  ElevatedButton(
                    onPressed: _editProfile,
                    child: const Text('Edit'),
                  ),
                // Save Button
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
