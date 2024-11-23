import 'package:flutter/material.dart';

// Product Model for Ration Shop
class Product {
  final String image;
  final String name;
  final double price;

  Product({required this.image, required this.name, required this.price});
}

class UserPurchase extends StatefulWidget {
  @override
  _UserPurchaseState createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {
  // List of common products found in Indian Government ration shops
  final List<Product> products = [
    Product(image: 'asset/rawrice.jpeg', name: 'Raw Rice (1kg)', price: 2.0),
    Product(image: 'asset/rice.jpeg', name: 'Rice (1kg)', price: 2.0),
    Product(image: 'asset/wheat.jpeg', name: 'Wheat (1kg)', price: 5.0),
    Product(image: 'asset/kerosine.jpeg', name: 'Kerosine (1L)', price: 50.0),
    Product(image: 'asset/atta.jpeg', name: 'Atta (1kg)', price: 12.0),
    Product(image: 'asset/sugar.jpeg', name: 'sugar (1kg)', price: 25.0),
    
  ];

  // List to store cart items
  List<Product> _cart = [];

  // Method to add product to cart
  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
  }

  // Method to calculate total price of items in cart
  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cart) {
      total += item.price;
    }
    return total;
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
          // Product List
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text('₹${product.price}', style: TextStyle(fontSize: 14, color: Colors.green)),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.blue),
                      onPressed: () {
                        _addToCart(product); // Add product to cart
                      },
                    ),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 10),
                Text('Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}', style: TextStyle(fontSize: 18, color: Colors.green)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _cart.isNotEmpty
                      ? () {
                          // Show order confirmation dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Order Placed'),
                              content: Text('Your order has been placed successfully!'),
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
                        }
                      : null,
                  child: Text('Place Order', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,  // Replaced `primary` with `backgroundColor`
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

void main() {
  runApp(MaterialApp(
    title: 'Ration Shop - User Purchase',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: UserPurchase(),
  ));
}
