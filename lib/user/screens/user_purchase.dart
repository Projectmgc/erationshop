import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// Product Model for Ration Shop
class Product {
  final String image;
  final String name;
  final double price;
  final int quantityAvailable;

  Product({
    required this.image,
    required this.name,
    required this.price,
    required this.quantityAvailable,
  });

  // Factory method to create a Product from a snapshot
  factory Product.fromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value as Map<dynamic, dynamic>;
    return Product(
      image: value['image'],
      name: value['name'],
      price: value['price'],
      quantityAvailable: value['quantityAvailable'],
    );
  }
}

class UserPurchase extends StatefulWidget {
  @override
  _UserPurchaseState createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {
  // Reference to Firebase Realtime Database
  final DatabaseReference _productRef = FirebaseDatabase.instance.ref().child('products');
  List<Product> _cart = [];

  // Add product to cart
  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
  }

  // Calculate total price of items in cart
  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cart) {
      total += item.price;
    }
    return total;
  }

  // Handle order placement and navigate to payment screen
  void _placeOrder() {
    // Navigate to payment section (replace with actual PaymentPage)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(totalAmount: _calculateTotalPrice())),
    );
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
          // Product List using StreamBuilder to listen to changes in Firebase
          Expanded(
            child: StreamBuilder(
              stream: _productRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Text("No products available"));
                }

                var data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Product> products = [];
                data.forEach((key, value) {
                  products.add(Product.fromSnapshot(snapshot.data!.snapshot.child(key)));
                });

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return product.quantityAvailable > 0 // Only show products with stock
                        ? Card(
                            margin: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.image, // Displaying image from URL
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              subtitle: Text('₹${product.price} - ${product.quantityAvailable} available',
                                  style: TextStyle(fontSize: 14, color: Colors.green)),
                              trailing: IconButton(
                                icon: Icon(Icons.add_shopping_cart, color: Colors.blue),
                                onPressed: () {
                                  if (product.quantityAvailable > 0) {
                                    _addToCart(product);
                                  }
                                },
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  },
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 10),
                Text('Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Colors.green)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _cart.isNotEmpty ? _placeOrder : null,
                  child: Text('Place Order', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle payment logic
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Payment Successful'),
                    content: Text('Your payment has been successfully processed!'),
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
