import 'package:erationshop/user/screens/user_purchase.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// HomeScreen Page (For example)
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class OwnerPurchase extends StatefulWidget {
  @override
  _OwnerPurchaseState createState() => _OwnerPurchaseState();
}

class _OwnerPurchaseState extends State<OwnerPurchase> {
  final TextEditingController _cardNoController = TextEditingController();
  bool _isSubmitting = false;

  // Function to save the card number in SharedPreferences
  Future<void> _saveCardNo() async {
    setState(() {
      _isSubmitting = true;
    });

    // Retrieve SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the card number
    String card_no = _cardNoController.text;
    if (card_no.isNotEmpty) {
      await prefs.setString('card_no', card_no);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card number saved successfully!')),
      );

      // Navigate to HomeScreen after successful submission
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return UserPurchase();
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid card number')),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Purchase',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Card Number',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cardNoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 180, 177, 175),
                labelText: 'Card Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _saveCardNo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 177, 175),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(fontSize: 18,color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OwnerPurchase(),
  ));
}
