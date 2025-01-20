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
  bool _isEligibleForPurchase = false;
  List<Map<dynamic, dynamic>> _purchasedItems = [];

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

  Future<void> _fetchPurchasedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cardId = prefs.getString('card_no');

    if (cardId != null) {
      try {
        QuerySnapshot querySnapshot = await firestore
            .collection('Orders')
            .where('user_id', isEqualTo: cardId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _purchasedItems = querySnapshot.docs.map((doc) {
              return {
                'items': doc['items'],
                'total_amount': doc['total_amount'],
                'status': doc['status'],
                'payment_id': doc['payment_id'],
                'timestamp': doc['timestamp'],
              };
            }).toList();
          });
        }
      } catch (e) {
        print("Error fetching purchased items: $e");
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPurchasedItems();
  }

  Future<void> _fetchCardsFromFirestore() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cardId = prefs.getString('card_no');
    print(cardId);

    if (cardId != null) {
      await _checkEligibilityForPurchase(cardId);
    }

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Card')
          .where('card_no', isEqualTo: cardId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No card found with card_no: $cardId');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final cardData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final categoryId = cardData['category_id'];

      if (categoryId == null) {
        print('Card document is missing category_id');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final categorySnapshot = await firestore
          .collection('Category')
          .doc(categoryId)
          .get();

      final categoryData = categorySnapshot.data() as Map<String, dynamic>?;

      if (categoryData == null) {
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
            bool isOrdered = false;

            orderQuerySnapshot.docs.forEach((e) {
              if (e.data()['items']
                  .any((e) => e['id'] == productInfo['product_id'])) {
                isOrdered = true;
              }
            });

            final productDoc = await firestore
                .collection('Product_Category')
                .doc(productInfo['product_id'])
                .get();

            final productData = productDoc.data();
            if (productData != null) {
              double productPrice = double.parse(productInfo['price']);
              double productQuantity = double.parse(productInfo['quantity']);
              double totalProductPrice = productPrice * productQuantity *
                  double.parse(querySnapshot.docs.first['members_count'].toString());

              _products.add({
                'id': productInfo['product_id'],
                'price': productPrice,
                'isOrdered': isOrdered,
                'total': totalProductPrice,
                'image': productData['image'],
                'quantity': productQuantity *
                    double.parse(querySnapshot.docs.first['members_count'].toString()),
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

  Future<void> _checkEligibilityForPurchase(String cardId) async {
    try {
      if (cardId == null) {
        setState(() {
          _isEligibleForPurchase = false;
        });
        return;
      }

      QuerySnapshot cardQuerySnapshot = await firestore
          .collection('Card')
          .where('card_no', isEqualTo: cardId)
          .limit(1)
          .get();

      if (cardQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot cardDoc = cardQuerySnapshot.docs.first;
        Timestamp? lastPurchaseTimestamp = cardDoc['last_purchase_date'];
        DateTime lastPurchaseDate = lastPurchaseTimestamp?.toDate() ?? DateTime.now().subtract(const Duration(days: 31));
        DateTime currentDate = DateTime.now();
        bool isEligible = currentDate.month != lastPurchaseDate.month || currentDate.year != lastPurchaseDate.year;

        setState(() {
          _isEligibleForPurchase = isEligible;
        });
      } else {
        setState(() {
          _isEligibleForPurchase = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card not found.')),
        );
      }
    } catch (e) {
      setState(() {
        _isEligibleForPurchase = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking eligibility: $e')) ,
      );
    }
  }

  void _addToCart(Map<dynamic, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cardId = prefs.getString('card_no');

    if (cardId != null) {
      await _checkEligibilityForPurchase(cardId);

      if (!_isEligibleForPurchase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not eligible to make a purchase this month.')),
        );
        return;
      }

      try {
        setState(() {
          _cart.add(product);
        });

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
          SnackBar(content: Text('Error adding to cart: $e')) ,
        );
      }
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cart) {
      total += item['total'] ?? 0.0;
    }
    return total;
  }

  Future<void> _placeOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final cardNo = prefs.getString('card_no');

      if (cardNo != null) {
        double totalAmount = _calculateTotalPrice() * 100;
        var options = {
          'key': 'rzp_test_QLvdqmBfoYL2Eu',
          'amount': totalAmount.toString(),
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating payment: $e')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cardNo = prefs.getString('card_no');

    if (cardNo != null) {
      try {
        await firestore.collection('Orders').add({
          'user_id': cardNo,
          'items': _cart,
          'total_amount': _calculateTotalPrice(),
          'payment_id': response.paymentId,
          'status': 'Success',
          'timestamp': FieldValue.serverTimestamp(),
        });

        QuerySnapshot cardQuerySnapshot = await firestore
            .collection('Card')
            .where('card_no', isEqualTo: cardNo)
            .limit(1)
            .get();

        if (cardQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot cardDoc = cardQuerySnapshot.docs.first;
          await firestore.collection('Card').doc(cardDoc.id).update({
            'last_purchase_date': FieldValue.serverTimestamp(),
          });
        }

        _removeAllFromCart();

        await _fetchCardsFromFirestore();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating last purchase date: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID is missing!')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _removeFromCart(Map<dynamic, dynamic> product) {
    setState(() {
      _cart.removeWhere((item) => item['id'] == product['id']);
    });
  }

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
        title: Text('User Purchase',style: TextStyle(color: Colors.white),),
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
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
                                title: Text(
                                  'Card No: ${card['card_no']}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Text('Category: ${card['category']}'),
                                trailing: Text('Members: ${card['members']}'),
                              ),
                              Divider(),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: ₹${_calculateTotalPrice()}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 10, 10, 10),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 171, 169, 168),
                          ),
                          child: Text('Place Order', style: TextStyle(fontSize: 18,color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  _purchasedItems.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purchased Items',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _purchasedItems.length,
                                itemBuilder: (context, index) {
                                  final purchasedItem = _purchasedItems[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text('Order ID: ${purchasedItem['payment_id']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Status: ${purchasedItem['status']}'),
                                          Text('Total Amount: ₹${purchasedItem['total_amount']}'),
                                          Text('Date of Purchase: ${purchasedItem['timestamp'].toDate()}'),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: (purchasedItem['items'] as List).map<Widget>((item) {
                                              return Text('Item: ${item['name']}  Quantity: ${item['quantity']}');
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<dynamic, dynamic> product;
  final bool isAddedToCart;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  ProductCard({
    required this.product,
    required this.isAddedToCart,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      child: ListTile(
        leading: Image.network(product['image'], width: 50, height: 50),
        title: Text(product['name']),
        subtitle: Text('₹${product['price']} x ${product['quantity']}'),
        trailing: isAddedToCart
            ? IconButton(
                icon: Icon(Icons.remove_shopping_cart),
                onPressed: onRemoveFromCart,
              )
            : IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: onAddToCart,
              ),
      ),
    );
  }
}
