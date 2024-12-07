
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth_Services
{
  final firebaseauth= FirebaseAuth.instance;
  void User_Register({required String name, required int cardno,required String email, required String password,required BuildContext context} )
  {
    try{
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(content: Text('Registration Successfull '),)));
    }
    catch(e){
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(content: Text('Registration Failed '),)));

    }
  }
}