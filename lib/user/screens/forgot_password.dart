import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Forgot_Password extends StatefulWidget {
  const Forgot_Password({super.key});

  @override
  State<Forgot_Password> createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());

  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String _otp = ''; // This will simulate the OTP

  // Simulate sending OTP
  void _sendOtp() {
    setState(() {
      _isOtpSent = true;
      _otp = '1234'; // Hardcoded OTP for demo purposes
    });
  }

  // Simulate OTP verification
  void _verifyOtp() {
    String enteredOtp = _otpControllers.map((controller) => controller.text).join();
    if (enteredOtp == _otp) {
      setState(() {
        _isOtpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/bggrains.jpg'), // Your background image
            fit: BoxFit.cover,
            opacity: 0.6,
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
                  'Forgot Password',
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

                // Phone Number Input Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your phone number',
                      style: GoogleFonts.merriweather(
                        color: const Color.fromARGB(255, 12, 12, 12),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 225, 157, 68),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    prefixIcon: Icon(Icons.phone),
                    
                        
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: 'Enter your phone number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty||value.length!=10) {
                          return 'Please enter valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(121, 209, 148, 101)),
                        shadowColor: WidgetStatePropertyAll(Color.fromARGB(159, 57, 31, 5)),
                                            elevation: WidgetStatePropertyAll(10.0),


                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Trigger OTP send logic
                          _sendOtp();
                        }
                      },
                      child: Text('Send OTP',style: TextStyle(color: const Color.fromARGB(228, 6, 6, 6),fontWeight: FontWeight.bold,fontSize: 18),),
                    ),
                  ],
                ),

                // OTP Input Section (appears after sending OTP)
                if (_isOtpSent && !_isOtpVerified)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter the OTP sent to your phone',
                        style: GoogleFonts.merriweather(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 50,
                            child: TextFormField(
                              controller: _otpControllers[index],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 225, 157, 68),
                                border: OutlineInputBorder(),
                                hintText: '•',
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context).nextFocus(); // Move to next field
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter OTP';
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                         style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(121, 209, 148, 101)),
                        shadowColor: WidgetStatePropertyAll(Color.fromARGB(159, 57, 31, 5)),
                                            elevation: WidgetStatePropertyAll(10.0),


                      ),
                        onPressed: _verifyOtp,
                        child: Text('Verify OTP',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: const Color.fromARGB(228, 6, 6, 6)),),
                      ),
                    ],
                  ),

                // Success message after OTP is verified
                if (_isOtpVerified)
                  Column(
                    children: [
                      Text(
                        'Your OTP has been verified. You can now reset your password.',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 2, 78, 4),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                         style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(121, 209, 148, 101)),
                        shadowColor: WidgetStatePropertyAll(Color.fromARGB(159, 57, 31, 5)),
                                            elevation: WidgetStatePropertyAll(10.0),


                      ),
                        onPressed: () {
                          // Navigate to Reset Password Page
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                        },
                        child: Text('Go to Reset Password',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18, color: const Color.fromARGB(228, 6, 6, 6)),),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
