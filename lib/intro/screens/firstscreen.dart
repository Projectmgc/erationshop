import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:erationshop/admin/screens/admin_login.dart';
import 'package:erationshop/owner/screens/login1_screen.dart';
import 'package:erationshop/user/screens/login_screen.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  @override
  void initState() {
    super.initState();
    // No need to wait 5 seconds, the "Login as" button will be visible immediately
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background from white to light brown
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(220, 218, 125, 19)], // White to light brown gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between children
          children: [
            // Centered content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular cropped Lottie Animation
                    Container(
                      height: 150, // Lottie size
                      width: 150, // Lottie size
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Circular shape
                        border: Border.all(
                          color: const Color.fromARGB(255, 227, 190, 68),
                          width: 5,
                        ),
                      ),
                      child: ClipOval(
                        child: Lottie.asset(
                          'asset/logo.json', // Add the path to your Lottie file
                          fit: BoxFit.cover, // Ensures Lottie fits in the circular shape
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 'E-RATION' Text
                    Text(
                      'E-RATION',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 84, 61, 2),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            
            // "Login as" button at the bottom of the screen
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  _showLoginPopup();
                },
                child: Text('Login as'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 212, 149, 101), // Brownish color for the button
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 67, 46, 4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the dialog for selecting user type
  void _showLoginPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 228, 165, 92), // Light brown color for the popup box
          title: Text(
            'Select User Type',
            style: TextStyle(color: const Color.fromARGB(255, 93, 66, 7)), // White title text color
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _userTypeButton('Admin', _navigateToAdmin),
              _userTypeButton('Owner', _navigateToOwner),
              _userTypeButton('User', _navigateToCustomer),
            ],
          ),
        );
      },
    );
  }

  // Function to create a button for selecting user type
  Widget _userTypeButton(String userType, Function onPressed) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Close the dialog immediately
        onPressed(); // Navigate to respective page
      },
      child: Text(userType),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 241, 220, 204), // Button color inside the dialog
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: TextStyle(fontSize: 18, color: Colors.white), // White text color for options
      ),
    );
  }

  // Function to navigate to the Admin page
  void _navigateToAdmin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Admin_Login();
    }));
  }

  // Function to navigate to the Owner page
  void _navigateToOwner() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Login1_Screen();
    }));
  }

  // Function to navigate to the Customer page
  void _navigateToCustomer() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Login_Screen();
    }));
  }
}
