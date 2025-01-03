import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Otp1_Screen extends StatefulWidget {
  const Otp1_Screen({super.key});

  @override
  State<Otp1_Screen> createState() => _Otp1_ScreenState();
}

class _Otp1_ScreenState extends State<Otp1_Screen> {
  final _formKey = GlobalKey<FormState>();


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'asset/logo.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 55),
                Text(
                  'Verify the OTP',
                  style: GoogleFonts.merriweather(
                    color: const Color.fromARGB(255, 81, 50, 12),
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: const Color.fromARGB(255, 160, 155, 155),
                        offset: Offset(-3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 45),
             
               
                
                 
                   
              ],
            ),
          ),
        ),
      ),
    );
  }
}
