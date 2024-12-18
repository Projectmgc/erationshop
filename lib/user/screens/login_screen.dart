import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erationshop/user/screens/forgot_password.dart';
import 'package:erationshop/user/screens/otp_screen.dart';
import 'package:erationshop/user/screens/signup_screen.dart';
import 'package:erationshop/user/screens/uhome_screen.dart';
import 'package:erationshop/user/services/User_firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController card_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  bool passwordVisible = true;
  bool loading = false;

  // This function will handle the login process
 // This function will handle the login process
void login() async {
  setState(() {
    loading = true; // Set loading to true while performing login
  });

  // Fetch the email, password, and card number entered by the user
  String email = email_controller.text;
  String password = password_controller.text;
  String cardno = card_controller.text;

  try {
    // Fetch the User document based on card number
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot userSnapshot = await firestore
        .collection('User')
        .where('card_no', isEqualTo: cardno)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
        print(userSnapshot.docs.length);

    if (userSnapshot.docs.isNotEmpty) {
    
      // User with the given card number and email exists
      var userDoc = userSnapshot.docs.first;

      // Check if the password matches (assuming it's stored as plain text or you have a hashing mechanism)
      if (userDoc['password'] == password) { 
        // If password matches, store the card number in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('card_no', cardno);
         print("object");  // Save the card number in SharedPreferences

        // Navigate to the next screen (UhomeScreen in this case)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UhomeScreen()), // Replace 'UhomeScreen' with your next page
        );
      } else {
        // If password doesn't match, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect password')),
        );
      }
    } else {
      // If no user is found with the given card number and email, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card number or email does not exist')),
      );
    }
  } catch (e) {
    print(e);
    // Handle errors, if any
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }

  setState(() {
    loading = false; // Set loading to false after login attempt
  });
}

  void forgotpassword() {
    // Navigate to Forgot Password Screen
  }

  void gotosignup() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Signup_Screen();
    }));
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
                Text(
                  'LOGIN',
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
                TextFormField(
                  controller: card_controller,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    hintText: 'Enter Card No',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the correct card number";
                    } else if (value.length != 10) {
                      return "Card number must be 10 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
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
                TextFormField(
                  controller: password_controller,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    suffixIconColor: const Color.fromARGB(198, 14, 1, 62),
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
                      icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
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
                TextButton(
                  onPressed: forgotpassword,
                  child: Text(
                    'Forgot password ?',
                    style: TextStyle(color: const Color.fromARGB(255, 11, 8, 1), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 40),
                loading ? CircularProgressIndicator():
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 225, 157, 68)),
                    shadowColor: WidgetStatePropertyAll(const Color.fromARGB(255, 62, 55, 5)),
                    elevation: WidgetStatePropertyAll(10.0),
                  ),
                  onPressed: login, // Call the login method here
                  child: Text(
                    'LOGIN',
                    style: TextStyle(color: const Color.fromARGB(255, 8, 6, 21), fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: const Color.fromARGB(255, 1, 4, 21), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: gotosignup,
                        child: Text(
                          'SignUp here',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: const Color.fromARGB(255, 10, 1, 61)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

