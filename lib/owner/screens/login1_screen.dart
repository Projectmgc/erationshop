import 'package:erationshop/owner/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login1_Screen extends StatefulWidget {
  const Login1_Screen({super.key});

  @override
  State<Login1_Screen> createState() => _Login1_ScreenState();
}

class _Login1_ScreenState extends State<Login1_Screen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController shopid_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  bool passwordVisible = true;
  bool loading = false;

  // Function to handle login
  void login() async {
    setState(() {
      loading = true; // Set loading to true while performing login
    });

    try {
      // Query Firestore for a matching Shop Owner document
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Shop Owner')
          .where('email', isEqualTo: email_controller.text)
          .where('shop_id', isEqualTo: shopid_controller.text)
          .get();

      // Check if the document exists
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          loading = false;
        });
        // No document found, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or shop ID')),
        );
        return;
      }

      // Get the matching document (there should be only one)
      final shopData = querySnapshot.docs.first;
      final storedPassword = shopData['password'];

      // Check if the password matches
      if (password_controller.text == storedPassword) {
        setState(() {
          loading = false;
        });

        // Store the shop_id and shop owner's docId in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('shop_id', shopid_controller.text);
        prefs.setString('shop_owner_doc_id', shopData.id); // Save Firestore doc ID

        // Proceed to the next screen or main app page after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OwnerHomeScreen()),
        );
      } else {
        setState(() {
          loading = false;
        });
        // Show error if password doesn't match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect password')),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      // Handle any errors during Firestore query or authentication
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 245, 184, 93),
              const Color.fromARGB(255, 233, 211, 88),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'asset/logo.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 55),
                Text(
                  'OWNER LOGIN',
                  style: GoogleFonts.merriweather(
                    color: const Color.fromARGB(255, 81, 50, 12),
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: const Color.fromARGB(255, 160, 155, 155),
                        offset: Offset(-3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 45),
                // Email Input Field
                TextFormField(
                  controller: email_controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Enter your email address",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email address";
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Shop ID Input Field
                TextFormField(
                  controller: shopid_controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    hintText: 'Enter Store Id',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the correct store id";
                    } else if (value.length != 5) {
                      return "Store Id must be 5 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Password Input Field
                TextFormField(
                  controller: password_controller,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    suffixIconColor: const Color.fromARGB(198, 14, 1, 62),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    hintText: 'Enter Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter correct password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                // Login Button
                loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 225, 157, 68)),
                          shadowColor: MaterialStateProperty.all(const Color.fromARGB(255, 62, 55, 5)),
                          elevation: MaterialStateProperty.all(10.0),
                        ),
                        onPressed: login,
                        child: Text(
                          'LOGIN',
                          style: TextStyle(color: const Color.fromARGB(255, 8, 6, 21), fontWeight: FontWeight.bold),
                        ),
                      ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
