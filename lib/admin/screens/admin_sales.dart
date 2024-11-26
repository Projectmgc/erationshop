import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy sales data
    final List<Map<String, dynamic>> salesData = [
      {"date": "2024-11-01", "item": "Product A", "amount": 50.0},
      {"date": "2024-11-02", "item": "Product B", "amount": 75.0},
      {"date": "2024-11-03", "item": "Product C", "amount": 100.0},
    ];

    // Calculate total sales
    double totalSales = salesData.fold(0, (sum, item) => sum + item["amount"]);

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Analysis')),
      body: Column(
        children: [
          // Total sales summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Sales',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${totalSales.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pie Chart
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 300, // Increase size for better visibility
              child: PieChart(
                PieChartData(
                  sections: salesData
                      .map((data) => PieChartSectionData(
                            value: data["amount"],
                            title: '${data["item"]}\n${((data["amount"] / totalSales) * 100).toStringAsFixed(1)}%',
                            color: Colors.primaries[salesData.indexOf(data) % Colors.primaries.length],
                            radius: 80, // Make the chart sections larger
                            titleStyle: const TextStyle(
                              fontSize: 16, // Increase text size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ))
                      .toList(),
                  sectionsSpace: 4,
                  centerSpaceRadius: 50, // Adjust center space size
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
          // Sales list
          Expanded(
            child: ListView.builder(
              itemCount: salesData.length,
              itemBuilder: (context, index) {
                final sale = salesData[index];
                return ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text(sale["item"]),
                  subtitle: Text('Date: ${sale["date"]}'),
                  trailing: Text('\$${sale["amount"].toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
