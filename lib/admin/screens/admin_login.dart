import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erationshop/admin/screens/admin_forgot.dart';
import 'package:erationshop/admin/screens/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Add Lottie import
import 'package:shared_preferences/shared_preferences.dart';

class Admin_Login extends StatefulWidget {
  const Admin_Login({super.key});

  @override
  State<Admin_Login> createState() => _Admin_LoginState();
}

class _Admin_LoginState extends State<Admin_Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  bool passwordVisible = true;
  bool loading = false;

  // Method to login using Firestore (without Firebase Authentication)
  void login() async {
    setState(() {
      loading = true; // Set loading to true while performing login
    });

    String email = email_controller.text;
    String password = password_controller.text;

    try {
      // Query Firestore to find the admin with the matching email and password
      var adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
      
      // Only store email in SharedPreferences if login is successful
      if (adminSnapshot.docs.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        // Notify user and navigate to AdminHome screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
      } else {
        // If no matching admin is found, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      // Handle errors during Firestore query
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() {
      loading = false; // Set loading to false after login attempt
    });
  }

  void forgotpassword() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AdminForgotPasswordPage();
    }));
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
                  const Color.fromARGB(255, 255, 255, 255),
                  const Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Main content
          Opacity(
            opacity: loading ? 0.3 : 1.0, // Apply low opacity when loading is true
            child: Padding(
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
                            'asset/logo.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 55),
                    // "Admin Login" centered header
                    Center(
                      child: Text(
                        'ADMIN LOGIN',
                        style: GoogleFonts.merriweather(
                          color: const Color.fromARGB(255, 0, 0, 0),
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
                        fillColor:const Color.fromARGB(255, 202, 196, 182),
                        prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                        hintText: 'Enter Email Id',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 0, 0, 0)),
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
                    // Password Field
                    TextFormField(
                      controller: password_controller,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:const Color.fromARGB(255, 202, 196, 182),
                        hintText: 'Enter Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 0, 0, 0)),
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
                    // Forgot Password Button
                    TextButton(
                      onPressed: forgotpassword,
                      child: Text(
                        'Forgot password ?',
                        style: TextStyle(color: const Color.fromARGB(255, 11, 8, 1), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Login Button with a smaller width
                    Center(
                      child: SizedBox(
                        width: 250, // Reduced width
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 202, 196, 182)),
                            shadowColor: MaterialStateProperty.all(const Color.fromARGB(255, 62, 55, 5)),
                            elevation: MaterialStateProperty.all(10.0),
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
          ),

          // Lottie animation (loading) positioned in the center
          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3), // Dim the background
                child: Center(
                  child: Lottie.asset(
                    'asset/loading.json', // Path to your Lottie animation file
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
