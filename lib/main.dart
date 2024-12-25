import 'package:erationshop/firebase_options.dart';
import 'package:erationshop/user/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
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

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: IntroPage()));
}
