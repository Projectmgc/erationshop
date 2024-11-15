import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  // Function to navigate to different pages
  void _onCardTapped(String cardType) {
    print('$cardType card clicked');
    // You can use Navigator to push to different screens here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar background color
        elevation: 10, // AppBar shadow
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'asset/logo.jpg', // Your logo image
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            // Spacing between logo and name
            SizedBox(width: 8), // Slight space between logo and text
            Text(
              'E-RATION', // Name next to the logo
              style: GoogleFonts.merriweather(
                color: const Color.fromARGB(255, 17, 17, 17),
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            // Spacer to push profile icon to the right end
            Spacer(),
            // Profile icon button
            IconButton(
              icon: CircleAvatar(
                // backgroundImage: AssetImage('assets/profile.jpg'), // User profile image
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.deepPurpleAccent),
              ),
              onPressed: () {
                // Handle profile button press (e.g., navigate to profile screen)
                print('Profile button pressed');
              },
            ),
          ],
        ),
        centerTitle: false, // Ensures the title is not centered
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            
            SizedBox(height: 20),
            
            // Cards Section
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Profile Card
                  _buildCard('Profile', Icons.person, Colors.blue, () {
                    _onCardTapped('Profile');
                  }),

                  // Purchase Card
                  _buildCard('Purchase', Icons.shopping_cart, Colors.green, () {
                    _onCardTapped('Purchase');
                  }),

                  // Outlet Card
                  _buildCard('Outlet', Icons.store, Colors.orange, () {
                    _onCardTapped('Outlet');
                  }),

                  // Card Card
                  _buildCard('Card', Icons.credit_card, Colors.purple, () {
                    _onCardTapped('Card');
                  }),

                  // Enquiry Card
                  _buildCard('Enquiry', Icons.help_outline, Colors.red, () {
                    _onCardTapped('Enquiry');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a clickable card
  Widget _buildCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
