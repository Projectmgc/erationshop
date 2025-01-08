import 'package:erationshop/firebase_options.dart';
import 'package:erationshop/intro/screens/firstscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? card_no;
String? shopId;
String? shopOwnerId ;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  card_no = prefs.getString('card_no');

  shopId = prefs.getString('shop_id');

  shopOwnerId = prefs.getString('shop_owner_doc_id');


  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: IntroPage()));
}