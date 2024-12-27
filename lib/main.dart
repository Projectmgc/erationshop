import 'package:erationshop/admin/screens/admin_home.dart';
import 'package:erationshop/firebase_options.dart';
import 'package:erationshop/intro/screens/firstscreen.dart';
import 'package:erationshop/user/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? card_no;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  card_no = prefs.getString('card_no');

<<<<<<< HEAD



  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: IntroPage()));
=======
  runApp(
      MaterialApp(debugShowCheckedModeBanner: false, home: AdminHomeScreen()));
>>>>>>> c226dd058b3c5252b202badeca98516b94ed94d7
}
