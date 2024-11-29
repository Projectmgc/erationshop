import 'package:erationshop/user/screens/login_screen.dart';
import 'package:flutter/material.dart';
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

  // List of card titles/content
  final List<String> cardContents = [
    'This is Card 1',
    'This is Card 2',
    'This is Card 3',
  ];

  // Controller for the PageView for smooth card transitions
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Splash screen background color
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
                return _buildCard(cardContents[index]);
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
      _navigateToLoginPage(); // After the last card, go to the Login Page
    }
  }

  // Function to skip the onboarding and navigate to the Login page
  void _skipToLogin() {
    _navigateToLoginPage();
  }

  // Function to navigate to the Login page
  void _navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login_Screen()),
    );
  }

  // Widget to build a card
  Widget _buildCard(String text) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24, // Larger text size for visibility
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Text color
            ),
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
