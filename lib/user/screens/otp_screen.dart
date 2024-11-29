import 'package:erationshop/user/screens/uhome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool _isResendEnabled = false;
  int _resendWaitTime = 30;

  final String _correctOtp = "123456"; // Hardcoded OTP for verification

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      String enteredOtp =
          _otpControllers.map((controller) => controller.text).join();
      if (enteredOtp == _correctOtp) {
        Navigator.push(context, MaterialPageRoute(builder: (context){
      return UhomeScreen();
    }));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            
            content: Text("OTP Verified Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Incorrect OTP. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendWaitTime = 15;
    });

    Future.delayed(const Duration(seconds: 1), () {
      for (int i = 1; i <= 15; i++) {
        Future.delayed(Duration(seconds: i), () {
          setState(() {
            _resendWaitTime--;
            if (_resendWaitTime == 0) {
              _isResendEnabled = true;
            }
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                ClipOval(
                  child: Image.asset(
                    'asset/logo.jpg', // Ensure the correct path
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 55),
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
                        offset: const Offset(-3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 45),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          counterText: "", // Remove character count
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(216, 162, 36, 0.737),
                      shadowColor: const Color.fromARGB(255, 62, 55, 5),
                      elevation: 10.0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      "Verify",
                      style: GoogleFonts.merriweather(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 36, 2, 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isResendEnabled
                      ? () {
                          // Resend OTP logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("OTP Resent!"),
                            ),
                          );
                          _startResendTimer();
                        }
                      : null,
                  child: Text(
                    _isResendEnabled
                        ? "Resend OTP"
                        : "Wait $_resendWaitTime seconds",
                    style: TextStyle(
                      color: _isResendEnabled
                          ? const Color.fromARGB(255, 81, 50, 12)
                          : const Color.fromARGB(255, 26, 3, 3),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
