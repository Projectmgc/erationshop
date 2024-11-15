
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Profile',
      'icon': Icons.person,
      'color': Colors.blue,
      'description': 'Manage your personal details and preferences.',
    },
    {
      'title': 'Purchase',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'description': 'Track and manage your purchases efficiently.',
    },
    {
      'title': 'Outlet',
      'icon': Icons.store,
      'color': Colors.orange,
      'description': 'Find the nearest stores and outlets.',
    },
    {
      'title': 'Card',
      'icon': Icons.credit_card,
      'color': Colors.purple,
      'description': 'View and manage your credit or debit cards.',
    },
    {
      'title': 'Enquiry',
      'icon': Icons.help_outline,
      'color': Colors.red,
      'description': 'Ask questions and get support instantly.',
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications,
      'color': Colors.teal,
      'description': 'Stay updated with the latest alerts and updates.',
    },
  ];

  void _onCardTapped(String cardType) {
    print('$cardType card clicked');
    // Add navigation logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Section: Logo, Title, and Profile Icon
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              ClipOval(
                child: 
                Image.asset(
                  'asset/logo.jpg', // Ensure path is correct and added to pubspec.yaml
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'E-RATION',
                style: GoogleFonts.merriweather(
                  color: const Color.fromARGB(255, 17, 17, 17),
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              Spacer(),
              IconButton(
                icon: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepPurpleAccent),
                ),
                onPressed: () {
                  print('Profile button pressed');
                },
              ),
              SizedBox(width: 16), // Add spacing to align properly
            ],
          ),
          SizedBox(height: 30), // Space between the header and cards
          // Cards Section
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return _buildPageCard(card);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(Map<String, dynamic> card) {
    return Center(
      child: Stack(
        alignment: Alignment.center, // Center all children inside the Stack
        children: [
          // Card Container
          GestureDetector(
            onTap: () => _onCardTapped(card['title']),
            child: Transform.rotate(
              angle: 0.05, // Slight tilt
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: card['color'],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(card['icon'], size: 100, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      card['title'],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Description with Animation
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  card['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: card['color'],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
