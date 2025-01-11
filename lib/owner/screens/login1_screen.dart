import 'package:erationshop/owner/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // Import the lottie package

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
      body: Stack(
        children: [
          // Background with gradient
          Container(
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
          ),
          
          // Main content (only shown when not loading)
          if (!loading) 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'asset/logo.jpg', // Replace with your logo
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 55),
                    // "Owner Login" centered header
                    Center(
                      child: Text(
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
                    ),
                    SizedBox(height: 45),
                    // Email Field
                    TextFormField(
                      controller: email_controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 225, 157, 68),
                        prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                        hintText: 'Enter Email Id',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 81, 50, 12)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the email id";
                        } else if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Shop ID Field
                    TextFormField(
                      controller: shopid_controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 225, 157, 68),
                        prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                        hintText: 'Enter Store Id',
                        prefixIcon: Icon(Icons.store),
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
                    // Password Field
                    TextFormField(
                      controller: password_controller,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 225, 157, 68),
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
                    SizedBox(height: 10),
                    // Forgot Password Button (Optional)
                    TextButton(
                      onPressed: () {
                        // Add forgot password functionality
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 11, 8, 1),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Login Button with smaller width, only visible when not loading
                    Center(
                      child: SizedBox(
                        width: 250, // Reduced width
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 225, 157, 68)),
                            shadowColor: WidgetStateProperty.all(const Color.fromARGB(255, 62, 55, 5)),
                            elevation: WidgetStateProperty.all(10.0),
                          ),
                          onPressed: login, // Call the login method here
                          child: Text(
                            'LOGIN',
                            style: TextStyle(color: const Color.fromARGB(255, 8, 6, 21), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),

          // Lottie animation (loading) positioned in the center with increased opacity
          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3), // Background with low opacity
                child: Center(
                  child: Lottie.asset(
                    'asset/loading.json', // Your Lottie file location
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    // Increase opacity by setting opacity to full (default opacity is 1)
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
