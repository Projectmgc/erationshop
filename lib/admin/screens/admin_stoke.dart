import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _shops;
  late Future<List<Map<String, dynamic>>> _products;

  @override
  void initState() {
    super.initState();
    _shops = fetchShops();
    _products = fetchProducts();
  }

  // Fetch all shops from the 'Shop Owner' collection
  Future<List<Map<String, dynamic>>> fetchShops() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Shop Owner').get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'store_name': doc['store_name'],
              'shop_id': doc['shop_id'],
              'name': doc['name'],
            })
        .toList();
  }

  // Fetch all products from the 'Product_Category' collection
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Product_Category').get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
              'image': doc['image'],
            })
        .toList();
  }

  // Fetch stock details from the 'Stock_Details' collection for a specific shop
 // Fetch stock details from the 'Stock_Details' collection for a specific shop
Future<Map<String, dynamic>> fetchStockDetails(String shopId) async {
  DocumentSnapshot docSnapshot = await _firestore.collection('Stock_Details').doc(shopId).get();
  
  if (!docSnapshot.exists) {
    // If the document doesn't exist, initialize it
    await initializeStock(shopId, await fetchProducts());
    // Re-fetch the stock details after initializing it
    docSnapshot = await _firestore.collection('Stock_Details').doc(shopId).get();
  }

  return docSnapshot.exists ? docSnapshot.data() as Map<String, dynamic> : {};
}

 // Initialize stock details when a new shop is added (if not already initialized)
Future<void> initializeStock(String shopId, List<Map<String, dynamic>> products) async {
  DocumentReference stockDoc = _firestore.collection('Stock_Details').doc(shopId);
  // Only initialize if stock document doesn't exist
  DocumentSnapshot stockSnapshot = await stockDoc.get();
  if (!stockSnapshot.exists) {
    Map<String, dynamic> stockData = {};
    for (int i = 0; i < products.length; i++) {
      stockData['product_${i + 1}'] = {
        'stockAllotted': 0,
        'currentStock': 0,
      };
    }
    await stockDoc.set({
      'shopId': shopId,
      'products': stockData,
    });
  }
}

  // Update stock details
// Update stock details
// Update stock details
Future<void> updateStock(String shopId, String productKey, int stockAllocated) async {
  // Get the document reference
  DocumentReference stockDoc = _firestore.collection('Stock_Details').doc(shopId);

  // Fetch the current stock data
  DocumentSnapshot stockSnapshot = await stockDoc.get();
  
  if (stockSnapshot.exists) {
    // Get the current values of stockAllotted and currentStock
    Map<String, dynamic> stockData = stockSnapshot.data() as Map<String, dynamic>;
    int currentStock = stockData['products'][productKey]['currentStock'] ?? 0;

    // Calculate the new values
    int newCurrentStock = currentStock + stockAllocated;
    int newStockAllotted = stockData['products'][productKey]['stockAllotted'] + stockAllocated;

    // Update both stockAllotted and currentStock
    await stockDoc.update({
      'products.$productKey.stockAllotted': newStockAllotted,
      'products.$productKey.currentStock': newCurrentStock,
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Stock Management')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _shops,
        builder: (context, shopSnapshot) {
          if (shopSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (shopSnapshot.hasError) {
            return Center(child: Text('Error loading shops'));
          } else if (!shopSnapshot.hasData || shopSnapshot.data!.isEmpty) {
            return Center(child: Text('No shops available'));
          }

          List<Map<String, dynamic>> shops = shopSnapshot.data!;

          return ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, shopIndex) {
              Map<String, dynamic> shop = shops[shopIndex];
              return FutureBuilder<Map<String, dynamic>>(
                future: fetchStockDetails(shop['id']),
                builder: (context, stockSnapshot) {
                  if (stockSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(shop['store_name']),
                      subtitle: Text('Loading stock details...'),
                    );
                  } else if (stockSnapshot.hasError) {
                    return ListTile(
                      title: Text(shop['store_name']),
                      subtitle: Text('Error loading stock details'),
                    );
                  } else if (!stockSnapshot.hasData) {
                    // Initialize stock if not available
                    initializeStock(shop['id'], []);
                    return ListTile(
                      title: Text(shop['store_name']),
                      subtitle: Text('Initializing stock...'),
                    );
                  }

                  Map<String, dynamic> stockData = stockSnapshot.data!;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(shop['store_name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _products,
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (productSnapshot.hasError) {
                                return Center(child: Text('Error loading products'));
                              } else if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                                return Center(child: Text('No products available'));
                              }

                              List<Map<String, dynamic>> products = productSnapshot.data!;

                              return Column(
                                children: products.map((product) {
                                  String productId = product['id'];
                                  String productName = product['name'];
                                  String productImage = product['image'];

                                  String productKey = 'product_${products.indexOf(product) + 1}';
                                  int currentStock = stockData['products']?[productKey]?['currentStock'] ?? 0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(productImage),
                                          radius: 25,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              width: 100,
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(labelText: 'Allotted Stock'),
                                                onChanged: (value) {
                                                  int? stockAllocated = int.tryParse(value);
                                                  if (stockAllocated != null) {
                                                    updateStock(shop['id'], productKey, stockAllocated);
                                                  }
                                                },
                                              ),
                                            ),
                                            Text(
                                              'Current Stock: $currentStock',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
