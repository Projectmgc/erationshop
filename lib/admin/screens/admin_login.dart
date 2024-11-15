import 'package:erationshop/admin/screens/admin_forgot.dart';
import 'package:erationshop/admin/screens/admin_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Admin_Login extends StatefulWidget {
  const Admin_Login({super.key});

  @override
  State<Admin_Login> createState() => _Admin_LoginState();
}

class _Admin_LoginState extends State<Admin_Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController card_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  bool passwordVisible = true;

  void forgotpassword()
  {
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return Admin_Forgot();
    }));
  }

 
  

  void otpverification() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, perform registration actions here
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return Admin_Otp();
        },
      ));
      
    }
  }

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
                  'OWNER LOGIN ',
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
             
                SizedBox(height: 10),
                TextFormField(
                  controller: card_controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    hintText: 'Enter Store Id',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the  correct store id";
                    } else if (value.length != 5) {
                      return "Store Id must be 5 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
               
                
                TextFormField(
                  controller: password_controller,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    suffixIconColor: const Color.fromARGB(198, 14, 1, 62),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 225, 157, 68),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    hintText: 'Enter Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2,color: const Color.fromARGB(255, 81, 50, 12)),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter correct password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextButton(onPressed: forgotpassword, child: Text('Forgot password ?',style:TextStyle(color: const Color.fromARGB(255, 11, 8, 1),fontSize: 15,fontWeight: FontWeight.bold))),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 225, 157, 68)),
                    shadowColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 62, 55, 5)),
                    elevation: WidgetStatePropertyAll(10.0),
                    
                  ),
                  onPressed: otpverification,
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                        
                        color: const Color.fromARGB(255, 8, 6, 21),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}