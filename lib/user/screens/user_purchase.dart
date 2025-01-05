import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPurchase extends StatefulWidget {
  @override
  _UserPurchaseState createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {
  List<Map<dynamic, dynamic>> _cards = [];
  List<Map<dynamic, dynamic>> _cart = [];
  List<Map<dynamic, dynamic>> _products = [];
  bool _isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _fetchCardsFromFirestore();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

Future<void> _fetchCardsFromFirestore() async {
  setState(() {
    _isLoading = true;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final cardId = prefs.getString('card_no');
  print(cardId);
  try {
    QuerySnapshot querySnapshot = await firestore
        .collection('Card')
        .where('card_no', isEqualTo: cardId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Handle the case where no card is found
      print('No card found with card_no: $cardId');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final cardData = querySnapshot.docs.first.data() as Map<String, dynamic>;
    final categoryId = cardData['category_id']; // Accessing by 'category_id'

    if (categoryId == null) {
      // Handle the case where 'category_id' is missing in the card document
      print('Card document is missing category_id');
      setState(() {
        _isLoading = false;
      });
      return;
    }


    final categorySnapshot = await firestore
        .collection('Category')
        .doc(categoryId) // Use categoryId here
        .get();

    final categoryData = categorySnapshot.data() as Map<String, dynamic>?;

     if (categoryData == null) {
      // Handle the case where category data is not found
      print('Category data not found for ID: $categoryId');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    List<Future<void>> productFutures = [];

    for (var productInfo in categoryData['product']) {
      productFutures.add(
        firestore
            .collection('Orders')
            
            .get()
            .then((orderQuerySnapshot) async {

              bool  isOrderd = false;

              orderQuerySnapshot.docs.forEach((e){
              if(e.data()['items'].any((e)=>e['id']==productInfo['product_id'])){
                  isOrderd= true;

              }         
                
                });
                print('oooooooo');

                print(isOrderd);
          
            // Fetch product details
            final productDoc = await firestore
                .collection('Product_Category')
                .doc(productInfo['product_id'])
                .get();

            final productData = productDoc.data();
            if (productData != null) {
              _products.add({
                'id': productInfo['product_id'],
                'price': productInfo['price'],
                'isOrderd':isOrderd,
                'total': double.parse(productInfo['price']) *
                    double.parse(querySnapshot.docs.first['members_count']),
                'image': productData['image'],
                'quantity': double.parse(productInfo['quantity']) *
                    double.parse(querySnapshot.docs.first['members_count']),
                'name': productData['name'],
                'description': productData['description'],
              });
            }
          
        }),
      );
    }

    await Future.wait(productFutures);

    _cards = querySnapshot.docs.map((doc) {
      return {
        'card_no': doc['card_no'],
        'category': categoryData['category_name'],
        'members': doc['members_count'],
        'mobile_no': doc['mobile_no'],
        'owner_name': doc['owner_name'],
      };
    }).toList();
  } catch (e) {
    print('Error fetching data: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  // Add product to cart
  void _addToCart(Map<dynamic, dynamic> product) async {
    try {
      setState(() {
        _cart.add(product);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('card_no');

      if (userId != null) {
        await firestore.collection('Cart').add({
          'user_id': userId,
          'product_id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': product['quantity'],
          'total': product['total'],
          'image': product['image'],
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} added to cart')),
        );
      } else {
        throw Exception("User ID not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
      print('Error adding to Firestore Cart collection: $e');
    }
  }

  // Remove product from cart
  void _removeFromCart(Map<dynamic, dynamic> product) async {
    try {
      setState(() {
        _cart.removeWhere((item) => item['id'] == product['id']);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('card_no');

      if (userId != null) {
        final cartQuery = await firestore
            .collection('Cart')
            .where('user_id', isEqualTo: userId)
            .where('product_id', isEqualTo: product['id'])
            .get();

        for (var doc in cartQuery.docs) {
          await doc.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product['name']} removed from cart')),
        );
      } else {
        throw Exception("User ID not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from cart: $e')),
      );
      print('Error removing from Firestore Cart collection: $e');
    }
  }

  // Calculate total price of items in cart
  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cart) {
      total += item['total'] ?? 0.0;
    }
    return total;
  }

  // Handle order placement and Razorpay payment
  void _placeOrder() async {
    try {
      if(_cart.isNotEmpty){
        double totalAmount = _calculateTotalPrice() * 100; // Convert to paise
      var options = {
        'key': 'rzp_test_QLvdqmBfoYL2Eu', // Your Razorpay key here
        'amount': totalAmount.toString(), // Amount in paise
        'name': 'Ration Shop',
        'description': 'Order Payment',
        'prefill': {
          'contact': '1234567890',
          'email': 'example@example.com'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
      }else{
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please add items in cart')),
      );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating payment: $e')),
      );
    }
  }

  // Payment Success handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('card_no');

    if (userId != null) {
      // Add the order to Firestore 'Orders' collection
      await firestore.collection('Orders').add({
        'user_id': userId,
        'items': _cart,
        'total_amount': _calculateTotalPrice(),
        'payment_id': response.paymentId,
        'status': 'Success',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove items from cart
      _removeAllFromCart();

      await _fetchCardsFromFirestore();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful!')),
      );
    }
  }

  // Payment Error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  // External Wallet handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  // Remove all items from cart
  void _removeAllFromCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('card_no');

    if (userId != null) {
      final cartQuery = await firestore
          .collection('Cart')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in cartQuery.docs) {
        await doc.reference.delete();
      }

      _cart.clear();
      _products.clear();
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ration Shop - User Purchase'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                                final isAddedToCart = _cart.any(
                                    (item) => item['id'] == product['id']);
                                return ProductCard(
                                  product: product,
                                  isAddedToCart: isAddedToCart,
                                  onAddToCart: () => _addToCart(product),
                                  onRemoveFromCart: () =>
                                      _removeFromCart(product),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Cart (${_cart.length} items)',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _placeOrder,
                        child: Text('Place Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

// Reusable ProductCard widget
class ProductCard extends StatelessWidget {
  final Map<dynamic, dynamic> product;
  final bool isAddedToCart;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isAddedToCart,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.orangeAccent.withOpacity(0.8), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(
                      product['image'] ?? 'https://via.placeholder.com/80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 15),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '₹${product['price']}/kg',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${product['quantity']} Kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Add/Remove Button
          product['isOrderd'] ? Icon(Icons.task_alt,color: Colors.green,) :   isAddedToCart
                ? ElevatedButton.icon(
                    onPressed: onRemoveFromCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.remove_shopping_cart, color: Colors.white),
                    label: Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                    label: Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
