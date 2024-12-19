import 'package:erationshop/admin/screens/admin_home.dart';
import 'package:erationshop/admin/screens/admin_login.dart';
import 'package:erationshop/firebase_options.dart';
import 'package:erationshop/intro/screens/firstscreen.dart';
import 'package:erationshop/owner/screens/home_screen.dart';
import 'package:erationshop/owner/screens/login1_screen.dart';
import 'package:erationshop/owner/screens/owner_selection.dart';
import 'package:erationshop/user/screens/forgot_password.dart';
import 'package:erationshop/user/screens/login_screen.dart';
import 'package:erationshop/user/screens/otp_screen.dart';
import 'package:erationshop/user/screens/reset_password.dart';
import 'package:erationshop/user/screens/signup_screen.dart';
import 'package:erationshop/user/screens/uhome_screen.dart';
import 'package:erationshop/user/screens/user_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(MaterialApp(debugShowCheckedModeBanner: false,home: StoreOwnerPage()),);


}                              