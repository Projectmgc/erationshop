import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erationshop/user/screens/login_screen.dart';

class Signup_Screen extends StatefulWidget {
  const Signup_Screen({super.key});

  @override
  State<Signup_Screen> createState() => _Signup_ScreenState();
}

class _Signup_ScreenState extends State<Signup_Screen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name_controller = TextEditingController();
  TextEditingController card_controller = TextEditingController();
  TextEditingController uid_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  bool passwordVisible = true;

  void gotologin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Login_Screen();
    }));
  }

  void registration() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, perform registration actions here
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return Login_Screen();
        },
      ));
      print("Name: ${name_controller.text}");
      print("Card No: ${card_controller.text}");
      print("UID No: ${uid_controller.text}");
      print("Password: ${password_controller.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/bgforsign.jpg'), // Add your image here
            fit: BoxFit.cover, // Make the image cover the entire screen
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
                        'asset/logoorg.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
                Text(
                  'Take The First Step ...',
                  style: GoogleFonts.pacifico(
                    color: Colors.black,
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
                SizedBox(height: 10),
                TextFormField(
                  controller: name_controller,
                  decoration: InputDecoration(
                    hintText: "Enter card owner's name",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 133, 194, 225),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the owner's name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: card_controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 133, 194, 225),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    hintText: 'Enter Card No',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the card number";
                    } else if (value.length != 10) {
                      return "Card number must be 10 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: uid_controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 133, 194, 225),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    prefixIconColor: const Color.fromARGB(255, 23, 2, 57),
                    hintText: 'Enter UID No',
                    prefixIcon: Icon(Icons.credit_card_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the UID number";
                    } else if (value.length != 12) {
                      return "Card number must be 12 digits";
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
                    fillColor: const Color.fromARGB(255, 133, 194, 225),
                    hoverColor: const Color.fromARGB(255, 2, 9, 49),
                    hintText: 'Enter Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
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
                      return "Please enter a password";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 146, 239, 215)),
                    shadowColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 30, 139, 121)),
                    elevation: WidgetStatePropertyAll(10.0),
                  ),
                  onPressed: registration,
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 15, 4, 67),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already sign up?',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        gotologin();
                      },
                      child: Text(
                        'Login here',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
