import 'package:erationshop/admin/screens/admin_login.dart';
import 'package:erationshop/owner/screens/login1_screen.dart';
import 'package:flutter/material.dart';
import 'package:erationshop/user/screens/login_screen.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // To track which card should be shown
  int _currentCardIndex = 0;

  // List of card titles/content related to e-ration shop theme
  final List<String> cardContents = [
    'Welcome to the E-Ration Shop!',
    'Experience the real ration buying feeling online, we have everything you need at your fingertips.',
    'No need to worry about your ration; we’ve got you covered with ordering monthly rations and ration card updates.',
  ];

  // List of image paths corresponding to each card
  final List<String> cardImages = [
    'asset/bggrains.jpg',
    'asset/bggrains.jpg',
    'asset/bggrains.jpg',
  ];

  // Controller for smooth card transitions
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 179, 29), // Splash screen background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // PageView to handle smooth card transitions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: cardContents.length,
              onPageChanged: (index) {
                setState(() {
                  _currentCardIndex = index; // Update the current card index
                });
              },
              itemBuilder: (context, index) {
                return _buildCard(cardContents[index], cardImages[index]);
              },
            ),
          ),
          // Row to hold Skip and Next buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button on the left
                ElevatedButton(
                  onPressed: _skipToLogin,
                  child: Text('Skip'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                // Next button on the right
                ElevatedButton(
                  onPressed: _nextCard,
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          // Card indicator at the bottom
          _buildCardIndicator(),
        ],
      ),
    );
  }

  // Function to navigate to the next card
  void _nextCard() {
    if (_currentCardIndex < cardContents.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showUserTypeDialog(); // Show the user type dialog after the last card
    }
  }

  // Function to skip the onboarding and navigate to the Login page
  void _skipToLogin() {
    _showUserTypeDialog();
  }

  // Function to show the dialog for selecting user type
  void _showUserTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select User Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _userTypeButton('Admin', _navigateToAdmin),
              _userTypeButton('Owner', _navigateToOwner),
              _userTypeButton('Client', _navigateToCustomer),
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
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }

  // Function to navigate to the Admin page
  void _navigateToAdmin() {
    Navigator.push(context,MaterialPageRoute(builder: (context){
      return Admin_Login();
      }));
  }

  // Function to navigate to the Owner page
  void _navigateToOwner() {
    Navigator.push(context,MaterialPageRoute(builder: (context){
      return Login1_Screen();
      }));
  }

  // Function to navigate to the Customer page
  void _navigateToCustomer() {
    Navigator.push(context,MaterialPageRoute(builder: (context){
      return Login_Screen();
      }));
  }

  // Widget to build a card with the image as the background covering the entire card
  Widget _buildCard(String text, String cardImage) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      child: Container(
        // Set image as background for the card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Rounded corners for the background
          image: DecorationImage(
            image: AssetImage(cardImage), // Set image as background
            fit: BoxFit.cover, // Cover the entire card
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 24, // Larger text size for visibility
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color for contrast
                ),
                textAlign: TextAlign.center, // Center the text
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the card indicator at the bottom
  Widget _buildCardIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        cardContents.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: _currentCardIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentCardIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
