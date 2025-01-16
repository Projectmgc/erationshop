import 'package:erationshop/main.dart';
import 'package:erationshop/owner/screens/owner_purchase.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:erationshop/user/screens/signup_screen.dart';
import 'package:erationshop/owner/screens/owner_enquiry.dart';
import 'package:erationshop/owner/screens/owner_notification.dart';
import 'package:erationshop/owner/screens/owner_outlet.dart';
import 'package:erationshop/owner/screens/owner_profile.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final PageController _pageController = PageController();
  String? shopId; // Nullable to handle loading state

  // Cards list with navigation targets
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Purchase',
      'color': Colors.lightGreenAccent,
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/purchase.jpg',
      'page': OwnerPurchase(),
    },
    {
      'title': 'Outlet',
      'color': Colors.amberAccent,
      'description': 'Find and Analyze the Ration Outlets.',
      'image': 'asset/outlet.jpg',
      'page': null, // Will handle separately in the logic
    },
    {
      'title': 'Enquiry',
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and Resolve Your Complaints.',
      'image': 'asset/enquiry.jpg',
      'page': null, // Will handle separately
    },
    {
      'title': 'Notification',
      'color': Colors.tealAccent,
      'description': 'New Updates and Notifications are here.',
      'image': 'asset/notification.jpg',
      'page': OwnerNotification(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  // Fetch the shopId from SharedPreferences
  Future<void> _loadShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shopId = prefs.getString('shop_id');
      shopOwnerId=prefs.getString('shop_owner_doc_id');
          });
  }


  void _onCardTapped(BuildContext context, Widget? page, String title) {
  if (page != null) {
    // Navigate to the given page if it’s not null
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  } else if (shopId != null) {
    // Handle the special cases where `page` is null
    if (title == 'Outlet') {
      // Handle navigation for Outlet card
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerOutletPage(shopId: shopOwnerId!),
        ),
      );
    } else if (title == 'Enquiry') {
      // Handle navigation for Enquiry card
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnquiryPage(shopId: shopId!),
        ),
      );
    }
  } else {
    // If no shopId found, show error
    _showErrorSnackBar(context, 'No shop ID found. Please log in again.');
  }
}



  // Navigate to owner profile page
  void _goToProfile() {
    if (shopId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(shopId: shopId!),
        ),
      );
    } else {
      _showErrorSnackBar(context, 'No shop ID found. Please log in again.');
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 245, 184, 93),
                  Color.fromARGB(255, 233, 211, 88),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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
                    const SizedBox(width: 10),
                    const Text(
                      'OWNER HOME',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      onPressed: _goToProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Cards Section
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _buildPageCard(context, card);
                  },
                ),
              ),

              // Dot indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _cards.length,
                  effect: const ExpandingDotsEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    activeDotColor: Colors.deepPurpleAccent,
                    dotColor: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build card for each item
  Widget _buildPageCard(BuildContext context, Map<String, dynamic> card) {
    return Center(
      child: GestureDetector(
        onTap: () => _onCardTapped(context, card['page'], card['title']),
        
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
                offset: const Offset(0, 10),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    card['title'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      card['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
