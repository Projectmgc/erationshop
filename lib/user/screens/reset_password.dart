import 'package:erationshop/user/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class Reset_Password extends StatefulWidget {
  const Reset_Password({super.key});

  @override
  State<Reset_Password> createState() => _Reset_PasswordState();
}

class _Reset_PasswordState extends State<Reset_Password> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordChanged = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Function to handle the password reset
  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPasswordController.text == _confirmPasswordController.text) {
        setState(() {
          _isPasswordChanged = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password Reset Successfully")),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)
    {
      return Login_Screen();
    }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match")),
        );
      }
    }
  }
  
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
                        'asset/logo.jpg', // Your logo image
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 55),
                Text(
                  'Reset Password',
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
                SizedBox(height: 30),

                // New Password Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your new password',
                      style: GoogleFonts.merriweather(
                        color: const Color.fromARGB(255, 12, 12, 12),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 225, 157, 68),
                        border: OutlineInputBorder(),
                        hintText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Confirm Password Input
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 225, 157, 68),
                        border: OutlineInputBorder(),
                        hintText: 'Confirm New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(121, 209, 148, 101)),
                        shadowColor: WidgetStatePropertyAll(Color.fromARGB(159, 57, 31, 5)),
                        elevation:WidgetStatePropertyAll(10.0),
                      ),
                      child: Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: const Color.fromARGB(228, 6, 6, 6))),
                    ),
                  ],
                ),

                // Success message after password reset
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
