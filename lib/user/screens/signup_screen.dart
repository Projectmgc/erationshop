import 'package:erationshop/user/screens/otp_screen.dart';
import 'package:erationshop/user/screens/login_screen.dart';
import 'package:erationshop/user/services/User_firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class Signup_Screen extends StatefulWidget {
  const Signup_Screen({super.key});

  @override
  State<Signup_Screen> createState() => _Signup_ScreenState();
}

class _Signup_ScreenState extends State<Signup_Screen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name_controller = TextEditingController();
  TextEditingController card_controller = TextEditingController();
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  bool passwordVisible = true;
  bool loading = false;

  // Method to navigate to Login Screen
  void gotologin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Login_Screen();
    }));
  }

  // Method for OTP Verification (you can modify this if necessary)
  void otpverification() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OtpScreen();
      }));
    }
  }

  // Method to handle signup with Firebase Authentication and Firestore
  void signp() async {
    setState(() {
      loading = true;
    });

    try {
      // Check if card exists in the Firestore collection 'Card'
      QuerySnapshot cardSnapshot = await FirebaseFirestore.instance
          .collection('Card')
          .where('card_no', isEqualTo: card_controller.text)
          .get();

      if (cardSnapshot.docs.isEmpty) {
        setState(() {
          loading = false;
        });
        // If no card is found, show an error message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Card number does not exist!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return; // Exit the function if card doesn't exist
      }

      // If the card exists, proceed with user authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email_controller.text,
        password: password_controller.text,
      );

      // After successful authentication, store the additional user details in Firestore
      await FirebaseFirestore.instance.collection('User').doc(userCredential.user!.uid).set({
        'name': name_controller.text,
        'card_id': cardSnapshot.docs.first.id, // Store the card ID from the Card collection
        'email': email_controller.text,
      });

      setState(() {
        loading = false;
      });

      // After successful signup, navigate to OTP screen
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return OtpScreen();
        },
      ));

      print("Name: ${name_controller.text}");
      print("Card No: ${card_controller.text}");
      print("Email: ${email_controller.text}");

    } catch (e) {
      setState(() {
        loading = false;
      });
      // Show error message if something went wrong during the signup process
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
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
                SizedBox(height: 45),
                Text(
                  'SIGN UP',
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
                  controller: name_controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: const Color.fromARGB(255, 81, 50, 12)),
                        borderRadius: BorderRadius.circular(10)),
                    hintText: "Enter card owner's name",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the owner's name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: card_controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    hintText: 'Enter Card No',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: const Color.fromARGB(255, 81, 50, 12)),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the card number";
                    } else if (value.length != 10) {
                      return "Card number must be 10 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: email_controller,
                  keyboardType: TextInputType.emailAddress, // Ensures the keyboard is optimized for email input
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: const Color.fromARGB(255, 81, 50, 12),
                      ),
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
                    // Basic email validation using regex
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
                    hintText: 'Create Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: const Color.fromARGB(255, 81, 50, 12)),
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 225, 157, 68)),
                          shadowColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 62, 55, 5)),
                          elevation: MaterialStateProperty.all(10.0),
                        ),
                        onPressed: signp,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 8, 6, 21),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already signed up?',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 1, 4, 21),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'merriweather'),
                    ),
                    TextButton(
                      onPressed: () {
                        gotologin();
                      },
                      child: Text(
                        'Login here',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'merriweather',
                            color: const Color.fromARGB(255, 10, 1, 61)),
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
