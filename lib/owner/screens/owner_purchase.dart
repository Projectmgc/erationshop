import 'package:flutter/material.dart';

// Define PurchasePage as a StatefulWidget to manage cart state
class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key, required String userId, required String username});

  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  // Cart items list
  List<Product> cartItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase Ration Products"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Banner or promotion (optional)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Get your monthly needs today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Products Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: productList[index],
                    onAddToCart: _addToCart, // Pass the callback to add item to cart
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to cart page to display cart items
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(cartItems: cartItems),
            ),
          );
        },
        child: Icon(Icons.shopping_cart),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Function to handle adding items to the cart
  void _addToCart(Product product) {
    setState(() {
      cartItems.add(product); // Add product to the cart
    });
    // Show a snackbar with feedback
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} added to cart!'),
      duration: Duration(seconds: 2),
    ));
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart; // Callback for adding to cart

  const ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.cover,
                height: 120,
              ),
            ),
          ),
          // Product Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                // Product Price
                Text(
                  '\₹${product.price}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 10),
                // Add to Cart Button
                ElevatedButton(
                  onPressed: () {
                    onAddToCart(product); // Call the callback to add product to cart
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16),
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

// Sample Product List
class Product {
  final String name;
  final String imagePath;
  final double price;

  Product({required this.name, required this.imagePath, required this.price});
}

// Sample products
List<Product> productList = [
  Product(name: "Boiled Rice", imagePath: 'asset/rice.jpeg', price: 50),
  Product(name: "Raw Rice", imagePath: 'asset/rawrice.jpeg', price: 40),
  Product(name: "Kerosene", imagePath: 'asset/kerosine.jpeg', price: 30),
  Product(name: "Wheat", imagePath: 'asset/wheat.jpeg', price: 45),
  Product(name: "Atta", imagePath: 'asset/Atta.jpeg', price: 35),
  Product(name: "Sugar", imagePath: 'asset/sugar.jpeg', price: 50),
];

// Cart Page to display added items
class CartPage extends StatelessWidget {
  final List<Product> cartItems;

  const CartPage({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
        backgroundColor: Colors.green,
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty."))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.asset(cartItems[index].imagePath, width: 50),
                  title: Text(cartItems[index].name),
                  subtitle: Text('\₹${cartItems[index].price}'),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle the checkout action here
                },
                child: Text("Proceed to Checkout"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.green,
                ),
              ),
            ),
    );
  }
}
