import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Outlet Details',
      theme: ThemeData(),
      initialRoute: '/',
      home: UserOutlet(),
    );
  }
}

class UserOutlet extends StatefulWidget {
  @override
  _UserOutletState createState() => _UserOutletState();
}

class _UserOutletState extends State<UserOutlet> {
  List<Map<String, dynamic>> outlets = [
    {
      'outletName': 'Best Outlet',
      'address': '123 Main Street, Cityville',
      'phone': '(123) 456-7890',
      'stock': [
        {'item': 'Product A', 'quantity': '50', 'price': '30.0', 'image': 'asset/rawrice.jpeg'},
        {'item': 'Product B', 'quantity': '20', 'price': '50.0', 'image': 'asset/rawrice.jpeg'},
      ]
    },
    {
      'outletName': 'Second Outlet',
      'address': '456 Elm Street, Townsville',
      'phone': '(234) 567-8901',
      'stock': [
        {'item': 'Product C', 'quantity': '100', 'price': '40.0', 'image': 'asset/rawrice.jpeg'},
        {'item': 'Product D', 'quantity': '60', 'price': '60.0', 'image': 'asset/rawrice.jpeg'},
      ]
    },
    {
      'outletName': 'Third Outlet',
      'address': '789 Pine Street, Villageburg',
      'phone': '(345) 678-9012',
      'stock': [
        {'item': 'Product E', 'quantity': '30', 'price': '25.0', 'image': 'asset/rawrice.jpeg'},
        {'item': 'Product F', 'quantity': '15', 'price': '70.0', 'image': 'asset/rawrice.jpeg'},
      ]
    },
    {
      'outletName': 'Fourth Outlet',
      'address': '101 Maple Street, Countryside',
      'phone': '(456) 789-0123',
      'stock': [
        {'item': 'Product G', 'quantity': '80', 'price': '35.0', 'image': 'asset/rawrice.jpeg'},
        {'item': 'Product H', 'quantity': '90', 'price': '55.0', 'image': 'asset/rawrice.jpeg'},
      ]
    },
    {
      'outletName': 'Fifth Outlet',
      'address': '202 Oak Street, Downtown',
      'phone': '(567) 890-1234',
      'stock': [
        {'item': 'Product I', 'quantity': '40', 'price': '45.0', 'image': 'asset/rawrice.jpeg'},
        {'item': 'Product J', 'quantity': '10', 'price': '80.0', 'image': 'asset/rawrice.jpeg'},
      ]
    },
  ];

  List<Map<String, dynamic>> filteredOutlets = [];
  bool isSearchVisible = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOutlets = outlets; // Initially display all outlets
  }

  void _filterOutlets(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOutlets = outlets;
      } else {
        filteredOutlets = outlets
            .where((outlet) =>
                outlet['outletName'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outlet Details'),
        backgroundColor: Color.fromARGB(255, 245, 184, 93),
        elevation: 0,
        actions: [
          // Display search icon, which when clicked, expands to a search field
          IconButton(
            icon: Icon(isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
                if (!isSearchVisible) {
                  searchController.clear();
                  _filterOutlets('');
                }
              });
            },
          ),
        ],
        bottom: isSearchVisible
            ? PreferredSize(
                preferredSize: Size.fromHeight(60.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterOutlets,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Search for a store...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Container(
        // Ensures that the background covers the entire screen by using Expanded
        height: double.infinity, // This ensures the container expands to fill the screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 245, 184, 93),
              const Color.fromARGB(255, 233, 211, 88),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (filteredOutlets.isEmpty)
                Center(
                  child: Text(
                    'No outlets found.',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              for (var outlet in filteredOutlets) _buildOutletCard(outlet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutletCard(Map<String, dynamic> outlet) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              outlet['outletName'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Address: ${outlet['address']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: ${outlet['phone']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Stock Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                for (var item in outlet['stock']) _buildStockItemCard(item),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItemCard(Map<String, String> item) {
    return Card(
      color: Colors.orange[50],
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  item['image']!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item']!,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Quantity: ${item['quantity']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Price: \$${item['price']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }}