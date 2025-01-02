import 'package:erationshop/owner/screens/owner_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'owner_profile.dart';
import 'owner_outlet.dart';
import 'owner_enquiry.dart';
import 'owner_notification.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final PageController _pageController = PageController();
  String shopId = '';
  Map<String, dynamic>? ownerData;

  // Updated _cards list without the "Card" page
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Purchase',
      'color': Colors.lightGreenAccent,
      'description': 'Keep track of available inventory and supplies.',
      'image': 'asset/purchase.jpg',
      'page': const StoreOwnerPage(), // Navigation target
    },
    {
      'title': 'Outlet',
      'color': Colors.amberAccent,
      'description': 'Find and Analyse the Ration Outlets.',
      'image': 'asset/outlet.jpg',
      'page': const OutletPage(), // Navigation target
    },
    {
      'title': 'Connverse',
      'color': Colors.pinkAccent.shade100,
      'description': 'Address and Resolve Your Complaints.',
      'image': 'asset/enquiry.jpg',
      'page': EnquiryPage(), // Navigation target
    },
    {
      'title': 'Notification',
      'color': Colors.tealAccent,
      'description': 'New Updates and Notifications are here.',
      'image': 'asset/notification.jpg',
      'page': OwnerNotification(), // Navigation target
    },
  ];

  @override
  void initState() {
    super.initState();
    _getShopId();
  }

  // Retrieve shop_id from SharedPreferences
  void _getShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shopId = prefs.getString('shop_id') ?? '';
    });

    if (shopId.isNotEmpty) {
      _fetchOwnerData(shopId);
    }
  }

  // Fetch shop owner data from Firestore
  void _fetchOwnerData(String shopId) async {
    try {
      // Query Firestore for the owner data using shop_id
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Shop Owner')
          .where('shop_id', isEqualTo: shopId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          ownerData = querySnapshot.docs.first.data();
        });
      }
    } catch (e) {
      // Handle any errors that occur during the Firestore query
      print('Error fetching owner data: $e');
    }
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
      MaterialPageRoute(
          builder: (context) => const ProfilePage(
                shopId: '',
              )),
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
              // Header Section with padding adjustments to move title and profile icon down
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SizedBox(
                        height: 30), // Added extra space to move elements down
                    Row(
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
                          'OWNER HOME',
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
                            child: Icon(Icons.person,
                                color: Colors.deepPurpleAccent),
                          ),
                          onPressed:
                              _goToProfile, // Navigate to the profile screen
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 40), // Move title and profile icon down more
                  ],
                ),
              ),
              // Cards Section with PageView.builder
              Expanded(
                child: Column(
                  children: [
                    // PageView Section
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
                    // Dot indicator (SmoothPageIndicator)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SmoothPageIndicator(
                        controller:
                            _pageController, // Controller to sync with PageView
                        count: _cards.length, // Number of dots
                        effect: ExpandingDotsEffect(
                          dotWidth: 12,
                          dotHeight: 12,
                          activeDotColor:
                              Colors.deepPurpleAccent, // Active dot color
                          dotColor: Colors.white
                              .withOpacity(0.5), // Inactive dot color
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
            borderRadius: BorderRadius.circular(30), // More rounded corners
            boxShadow: [
              BoxShadow(
                color: card['color'].withOpacity(0.6), // Softer shadow effect
                blurRadius: 25,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  card['image'],
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 20),
                  Text(
                    card['title'],
                    style: GoogleFonts.roboto(
                      fontSize: 30, // Increased size for better readability
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      card['description'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize:
                            18, // Slightly larger font for better readability
                        fontWeight:
                            FontWeight.w500, // Adjusted weight for clarity
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
