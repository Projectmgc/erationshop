import 'package:flutter/material.dart';

class Login_Screen extends StatelessWidget {
  const Login_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.red,),body: Text("hello",style:TextStyle(color: const Color.fromARGB(255, 207, 19, 231),fontSize: 94),),) ;
  }
}