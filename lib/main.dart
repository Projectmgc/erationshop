import 'package:erationshop/admin/screens/admin_home.dart';
import 'package:erationshop/firebase_options.dart';
import 'package:erationshop/intro/screens/firstscreen.dart';
import 'package:erationshop/owner/screens/home_screen.dart';
import 'package:erationshop/user/screens/uhome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? card_no;
String? shopId;
String? shopOwnerId;
String? emailadmin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences and check for login data
  SharedPreferences prefs = await SharedPreferences.getInstance();

  card_no = prefs.getString('card_no');
  shopId = prefs.getString('shop_id');
  shopOwnerId = prefs.getString('shop_owner_doc_id');
  emailadmin = prefs.getString('email');

  // Run the app with the appropriate home screen based on the stored data
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
    );
  }

  // Check the stored data and return the appropriate screen
  Widget _getInitialScreen() {
    if (card_no != null) {
      // If card_no is available, navigate to HomeScreen
      return UhomeScreen();
    } else if (shopId != null && shopOwnerId != null) {
      // If both shopId and shopOwnerId are available, navigate to Home1Screen
      return OwnerHomeScreen();
    } else if (emailadmin != null) {
      // If emailadmin is available, navigate to AdminHomeScreen
      return AdminHomeScreen();
    } else {
      // If none of the required data is available, navigate to the IntroPage
      return IntroPage();
    }
  }
}
