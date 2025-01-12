import 'package:erationshop/admin/screens/cardcategories.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'admin_product.dart'; // Import your AdminProductPage
import 'admin_profile.dart';
import 'admin_stoke.dart';
import 'admin_complaint.dart';
import 'admin_card.dart';
import 'admin_notification.dart';
import 'admin_shop.dart';
import 'admin.converse.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Stock',
      'icon': Icons.inventory,
      'color': Colors.lightGreenAccent,
      'description': 'Keep track of Ration Shops Stocks and add to it',
      'image': 'asset/stock.jpg',
      'page': StockPage(), // Navigation target
    },
    {
      'title': 'User Enquiry',
      'icon': Icons.report_problem,
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and resolve User complaints.',
      'image': 'asset/enquiry.jpg',
      'page': ComplaintsPage(), // Navigation target
    },
    {
      'title': 'Card',
      'icon': Icons.credit_card,
      'color': Colors.purpleAccent.shade100,
      'description': 'Manage Ration card-related operations.',
      'image': 'asset/card.jpg',
      'page': AddCardPage(), // Navigation target
    },
    {
      'title': 'Shop Enquiry',
      'icon': Icons.chat,
      'color': Colors.tealAccent,
      'description': 'Communicate with Shop Owners.',
      'image': 'asset/stock.jpg',
      'page': ConversePage(), // Navigation target
    },
    {
      'title': 'Card Categories',
      'icon': Icons.credit_card,
      'color': const Color.fromARGB(255, 53, 64, 61),
      'description': 'View and manage Categories of Cards.',
      'image': 'asset/card.jpg',
      'page': CategoryPage(), // Navigation target
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications,
      'color': Colors.orangeAccent,
      'description': 'View and manage important notifications.',
      'image': 'asset/notification.jpg',
      'page': AdminNotificationPage(), // Navigation target
    },
    {
      'title': 'Add Shops',
      'icon': Icons.shop,
      'color': Colors.blueAccent,
      'description': 'Add new Shop and Shop owner details.',
      'image': 'asset/outlet.jpg',
      'page': AdminShopPage(), // Navigation target for AdminShopPage
    },
    {
      'title': 'Add Product',
      'icon': Icons.add_box,
      'color': Colors.deepOrangeAccent,
      'description': 'Add new products to the stock.',
      'image': 'asset/outlet.jpg',
      'page': AdminProduct(), // Navigation target for AdminProductPage
    },
  ];

  // Function to handle infinite scrolling
  void _onPageChanged(int index) {
    if (index == _cards.length - 1) {
      _pageController.jumpToPage(0); // Reset to first page
    } else if (index == 0) {
      _pageController.jumpToPage(_cards.length - 0); // Go to the second last page
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.toInt();
      if (page != null) {
        _onPageChanged(page);
      }
    });
  }

  void _onCardTapped(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()), // Navigate to Profile screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16.0, right: 16.0), // Adjust padding to move it lower
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'asset/logo.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'E-RATION ADMIN\'S',
                      style: GoogleFonts.merriweather(
                        color: Colors.black87,
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
                      onPressed: _goToProfile, // Navigate to Profile screen
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: null, // Infinite pages
                        itemBuilder: (context, index) {
                          final card = _cards[index % _cards.length];
                          return _buildPageCard(card);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SmoothPageIndicator(
                        controller: _pageController, 
                        count: _cards.length, 
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Colors.deepPurpleAccent,
                          dotColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(Map<String, dynamic> card) {
    return Center(
      child: GestureDetector(
        onTap: () => _onCardTapped(card['page']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: card['color'].withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  card['image'],
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(card['icon'], size: 60, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    card['title'],
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      card['description'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
