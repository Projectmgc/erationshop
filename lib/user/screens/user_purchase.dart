import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPurchase extends StatefulWidget {
  @override
  _UserPurchaseState createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {
  List<Map<dynamic, dynamic>> _cards = [];
  List<Map<dynamic, dynamic>> _cart = [];
  List<Map<dynamic, dynamic>> _products = [];

  // Fetch cards from Firestore
  Future<void> _fetchCardsFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final card_id=prefs.getString('card_no');

    // Fetch the card collection from Firestore
    QuerySnapshot querySnapshot = await firestore.collection('Card').where('card_no',isEqualTo: card_id).limit(1).get();
    final categorySnapshot = await firestore.collection('Category').doc(querySnapshot.docs.first['category']).get();

    final categorydata=categorySnapshot.data();



   await categorydata!['product'].forEach((e) async{

      final productdata = await firestore.collection('Product_Category').doc(e['product_id']).get();
      _products.add({
        'price':e['price'],
        'quantity':double.parse(e['quantity']) *  double.parse(querySnapshot.docs.first['members']),
        'name' : productdata['name'],
        'description': productdata['description']
      });
    
      


    });

     _cards = querySnapshot.docs.map((doc) {
        return {
          'card_no': doc['card_no'],
          'category':categorydata!['category_name'] ,
          'members': doc['members'],
          'mobile_no': doc['mobile_no'],
          'owner_name': doc['owner_name'],
        };
      }).toList();


    // Map the fetched data to _cards list
    setState(() {


    });
  }


   
  // Dummy data for products
  
  // Add product to cart
  void _addToCart(Map<dynamic, dynamic> product) {
    setState(() {
      _cart.add(product);
    });
  }

  // Calculate total price of items in cart
  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cart) {
      total += double.tryParse(item['price']) ?? 0.0;
    }
    return total;
  }

  // Handle order placement and navigate to payment screen
  void _placeOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaymentPage(totalAmount: _calculateTotalPrice())),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCardsFromFirestore();
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ration Shop - User Purchase'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          // Card List using ListView to show available cards
          Expanded(
            child: ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];

                return Card(
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Card No: ${card['card_no']}'),
                        subtitle: Text('Category: ${card['category']}'),
                        trailing: Text('Members: ${card['members']}'),
                      ),
                      Divider(),
                      // Show products for this card category
                      Column(
                        children: _products.map((product) {
                          return Card(
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: ListTile(
                              title: Text(product['name']),
                              subtitle: Text(
                                  '₹${product['price']} - ${product['quantity']} available'),
                              trailing: IconButton(
                                icon: Icon(Icons.add_shopping_cart,
                                    color: Colors.blue),
                                onPressed: () {
                                  _addToCart(product);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Cart Summary and Place Order
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cart (${_cart.length} items)',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                SizedBox(height: 10),
                Text('Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, color: Colors.green)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _cart.isNotEmpty ? _placeOrder : null,
                  child: Text('Place Order', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy PaymentPage widget to represent the payment screen
class PaymentPage extends StatelessWidget {
  final double totalAmount;

  PaymentPage({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Payment Successful'),
                    content:
                        Text('Your payment has been successfully processed!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
