import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'admin_product.dart'; // Import your AdminProductPage
import 'admin_profile.dart';
import 'admin_stoke.dart';
import 'admin_sales.dart';
import 'admin_complaint.dart';
import 'admin_card.dart';
import 'admin_notification.dart';
import 'admin_shop.dart';
import 'admin.converse.dart';
import 'admin_request.dart'; // Import AdminRequestPage

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
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/stock.jpg',
      'page': StockPage(), // Navigation target
    },
    {
      'title': 'Sales',
      'icon': Icons.show_chart,
      'color': Colors.amberAccent,
      'description': 'Analyze and monitor your sales data.',
      'image': 'asset/sales.jpg',
      'page': SalesPage(), // Navigation target
    },
    {
      'title': 'Complaints',
      'icon': Icons.report_problem,
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and resolve customer complaints.',
      'image': 'asset/enquiry.jpg',
      'page': ComplaintsPage(), // Navigation target
    },
    {
      'title': 'Card',
      'icon': Icons.credit_card,
      'color': Colors.purpleAccent.shade100,
      'description': 'Manage credit or debit card-related operations.',
      'image': 'asset/card.jpg',
      'page': CardPage(), // Navigation target
    },
    {
      'title': 'Converse',
      'icon': Icons.chat,
      'color': Colors.tealAccent,
      'description': 'Communicate with your team or customers.',
      'image': 'asset/stock.jpg',
      'page': ConversePage(), // Navigation target
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications,
      'color': Colors.orangeAccent,
      'description': 'View and manage important notifications.',
      'image': 'asset/notification.jpg',
      'page': AdminNotificationPage(), // Navigation target
    },
    // New Card for AdminShopPage
    {
      'title': 'Shops',
      'icon': Icons.shop,
      'color': Colors.blueAccent,
      'description': 'Manage and view shop details.',
      'image': 'asset/outlet.jpg',
      'page': AdminShopPage(), // Navigation target for AdminShopPage
    },
    // New Card for AdminProductPage (Add Product to Stock)
    {
      'title': 'Add Product',
      'icon': Icons.add_box,
      'color': Colors.deepOrangeAccent,
      'description': 'Add new products to the stock.',
      'image': 'asset/outlet.jpg',
      'page': AdminProduct(), // Navigation target for AdminProductPage
    },
    // New Card for AdminRequestPage (Approve Member Requests)
    {
      'title': 'Member Requests',
      'icon': Icons.check_circle,
      'color': Colors.blueGrey,
      'description': 'Approve or reject member addition requests.',
      'image': 'asset/outlet.jpg', // Add your own image path
      'page': AdminRequest(), // Navigation target for AdminRequestPage
    },
  ];

  // Function to handle infinite scrolling
  void _onPageChanged(int index) {
    // Loop back to the first card when the last card is reached
    if (index == _cards.length - 1) {
      _pageController.jumpToPage(0); // Reset to first page
    } else if (index == 0) {
      _pageController.jumpToPage(_cards.length - 0); // Go to the second last page
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to handle page changes
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
          // Background gradient
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      'E-RATION ADMIN"S',
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
              // Cards Section with PageView.builder
              Expanded(
                child: Column(
                  children: [
                    // PageView Section
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
                    // Dot indicator (SmoothPageIndicator)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SmoothPageIndicator(
                        controller: _pageController, // Controller to sync with PageView
                        count: _cards.length, // Number of dots
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Colors.deepPurpleAccent, // Active dot color
                          dotColor: Colors.white.withOpacity(0.5), // Inactive dot color
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
