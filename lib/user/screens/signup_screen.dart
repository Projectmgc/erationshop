// import 'package:flutter/material.dart';

// class Signup_Screen extends StatefulWidget {
//   const Signup_Screen({super.key});

//   @override
//   State<Signup_Screen> createState() => _Signup_ScreenState();
// }

// class _Signup_ScreenState extends State<Signup_Screen> {
//   TextEditingController name_controller = TextEditingController();
//   TextEditingController card_controller = TextEditingController();
//   TextEditingController uid_controller = TextEditingController();
//   TextEditingController password_controller = TextEditingController();
//   bool passwordVisible = true;
//   void registration()
//   {

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
       
//         body: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'asset/logo.jpg',
//                     width: 65,
//                     height: 65,
//                   ),
//                   Text('dfghj')
//                 ],
//               ),
//               SizedBox(
//                 height: 45,
//               ),
//               TextField(
//                 controller: name_controller,
//                 decoration: InputDecoration(
//                   hintText: "Enter card owner's name",
//                   prefixIcon: Icon(Icons.person),
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               TextField(
//                 controller: card_controller,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter Card No',
//                   prefixIcon: Icon(Icons.book),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               TextField(
//                   controller: uid_controller,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'Enter UID No',
//                     prefixIcon: Icon(Icons.credit_card_rounded),
//                   )),
//               SizedBox(
//                 height: 20,
//               ),
//               TextField(
//                 controller: password_controller,
//                 obscureText: passwordVisible,
//                 decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'Enter Password ',
//                     suffixIcon: IconButton(
//                         onPressed: () {
//                           passwordVisible = !passwordVisible;
//                           setState(() {});
//                         },
//                         icon: Icon(passwordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off))),
//               ),
//               ElevatedButton(
//                   onPressed: () {
//                     print(name_controller.text);
//                     print(card_controller.text);
//                     print(uid_controller.text);
//                     print(password_controller.text);
//                     registration();
//                   },
//                   child: Text('SUBMIT'))
//             ],
//           ),
//         ));
//   }
// }



import 'package:erationshop/user/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void registration() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, perform registration actions here
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Login_Screen();
      },));
      print("Name: ${name_controller.text}");
      print("Card No: ${card_controller.text}");
      print("UID No: ${uid_controller.text}");
      print("Password: ${password_controller.text}");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/logo.jpg',
                    width: 65,
                    height: 65,
                  ),
                  Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(height: 45),
              TextFormField(
                controller: name_controller,
                decoration: InputDecoration(
                  hintText: "Enter card owner's name",
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: registration,
                child: Text('SUBMIT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
