import 'package:flutter/material.dart';

/// Mock Data for Villages and Stores
class Village {
  final String name;
  final List<Store> stores;

  Village({required this.name, required this.stores});
}

class Store {
  final String name;

  Store({required this.name});
}

class StockPage extends StatefulWidget {
  /// Constructor for [StockPage]
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final List<Village> _villages = [
    Village(
      name: 'Village A',
      stores: [
        Store(name: 'Store 1'),
        Store(name: 'Store 2'),
        Store(name: 'Store 3'),
      ],
    ),
    Village(
      name: 'Village B',
      stores: [
        Store(name: 'Store 4'),
        Store(name: 'Store 5'),
      ],
    ),
    // Add more villages as needed
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Village> _filteredVillages = [];

  @override
  void initState() {
    super.initState();
    _filteredVillages = _villages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10), // Spacer
          _buildVillageList(),
        ],
      ),
    );
  }

  /// Builds the Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search Villages or Stores',
          border: OutlineInputBorder(),
        ),
        onChanged: (query) {
          _filterSearchResults(query);
        },
      ),
    );
  }

  /// Filters search results based on the query
  void _filterSearchResults(String query) {
    final filtered = _villages.where((village) {
      return village.name.toLowerCase().contains(query.toLowerCase()) ||
          village.stores.any((store) => store.name.toLowerCase().contains(query.toLowerCase()));
    }).toList();
    setState(() {
      _filteredVillages = filtered;
    });
  }

  /// Builds the Village List as Buttons
  Widget _buildVillageList() {
    return Expanded(
      child: _filteredVillages.isEmpty
          ? const Center(child: Text('No Results Found'))
          : ListView.builder(
              itemCount: _filteredVillages.length,
              itemBuilder: (context, index) {
                final village = _filteredVillages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(village.name),
                    onTap: () {
                      // Navigate to the Store List Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StorePage(village: village),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class StorePage extends StatelessWidget {
  final Village village;

  const StorePage({super.key, required this.village});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${village.name} Stores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stores in ${village.name}:',
            ),
            const SizedBox(height: 8),
            ...village.stores.map((store) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(store.name),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
