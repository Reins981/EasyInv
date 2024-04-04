import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import 'add_item_screen.dart';

class DashboardScreen extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();
  late Stream<List<Item>> itemStreams;

  DashboardScreen({super.key});

  @override
  void initState() {
    super.initState();
    itemStreams = firestoreService.getAllItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
      ),
      body: FutureBuilder<List<Item>>(
        future: firestoreService.getAllItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No items in inventory.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 20),
                  _buildAddItemButton(context),
                ],
              ),
            );
          }

          // Calculate inventory statistics
          final totalItems = snapshot.data!.length;
          final totalCategories = snapshot.data!.map((item) => item.category).toSet().length;
          final lowStockItems = snapshot.data!.where((item) => item.quantity < 5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard('Total Items', totalItems),
                const SizedBox(height: 20),
                _buildStatCard('Total Categories', totalCategories),
                const SizedBox(height: 20),
                _buildLowStockItemsCard(lowStockItems),
                const SizedBox(height: 20),
                _buildInventoryChart(snapshot.data!),
                const SizedBox(height: 20),
                _buildAddItemButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.rosa,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockItemsCard(List<Item> lowStockItems) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.pink,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Low Stock Items',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 12.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                return ListTile(
                  title: Text(item.name, style: const TextStyle(color: AppColors.white)),
                  subtitle: Text('Category: ${item.category}', style: const TextStyle(color: AppColors.white)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryChart(List<Item> items) {
    final data = [
      charts.Series<Item, String>(
        id: 'Inventory',
        domainFn: (Item item, _) => item.name,
        measureFn: (Item item, _) => item.quantity,
        data: items,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.pink),
      ),
    ];

    return SizedBox(
      height: 300,
      child: charts.BarChart(
        data,
        animate: true,
        vertical: false,
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        domainAxis: const charts.OrdinalAxisSpec(renderSpec: charts.SmallTickRendererSpec(labelRotation: 60)),
      ),
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return Center( // Center widget added here
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.rosa,
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        child: const Text(
          'Add Item',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
