import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OwnerOrdersPage extends StatefulWidget {
  @override
  _OwnerOrdersPageState createState() => _OwnerOrdersPageState();
}

class _OwnerOrdersPageState extends State<OwnerOrdersPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await firestore.collection('Orders').get();

      setState(() {
        _orders = querySnapshot.docs.map((doc) {
          return {
            'order_id': doc.id,
            'status': doc['status'],
            'total_amount': doc['total_amount'],
            'timestamp': doc['timestamp'],
            'items': doc['items'],
            'purchased': doc['purchased'] ?? 'not purchased',
          };
        }).toList();

        _filteredOrders = List.from(_orders); // Initialize the filtered orders
      });
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders
          .where((order) => order['order_id']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _updatePurchaseStatus(String orderId) async {
    try {
      await firestore.collection('Orders').doc(orderId).update({
        'purchased': 'purchased',
      });

      // Fetch the updated orders
      _fetchOrders();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase status updated to "purchased"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating purchase status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Confirmation',style:TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Order ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterOrders(),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 5,
                          child: ListTile(
                            title: Text('Order ID: ${order['order_id']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${order['status']}'),
                                Text('Total Amount: ₹${order['total_amount']}'),
                                Text('Date: ${order['timestamp'].toDate()}'),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (order['items'] as List).map<Widget>((item) {
                                    return Text(
                                        'Item: ${item['name']}  Quantity: ${item['quantity']}');
                                  }).toList(),
                                ),
                                Text(
                                  'Purchase Status: ${order['purchased']}',
                                  style: TextStyle(
                                    color: order['purchased'] == 'Not Purchased'
                                        ? Colors.red
                                        : Colors.green, // Red for not purchased, Green for purchased
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: order['purchased'] == 'Not Purchased'
                                ? IconButton(
                                    icon: Icon(Icons.check_circle),
                                    onPressed: () => _updatePurchaseStatus(order['order_id']),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
