import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Admin_Otp extends StatefulWidget {
  const Admin_Otp({super.key});

  @override
  State<Admin_Otp> createState() => _Admin_OtpState();
}

class _Admin_OtpState extends State<Admin_Otp> {
  final _formKey = GlobalKey<FormState>();


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/bggrains.jpg'), // Add your image here
            fit: BoxFit.cover, 
            opacity: 0.70,// Make the image cover the entire screen
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
