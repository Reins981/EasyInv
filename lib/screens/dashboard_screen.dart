import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import 'add_item_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  Helper helper = Helper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Item>>(
            stream: firestoreService.getAllItems(),
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
                controller: _scrollController,
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
          Positioned(
            bottom: 80, // Position above the bottom button
            right: 16,
            child: FloatingActionButton(
              heroTag: 'vertical_align_top',
              mini: true,
              backgroundColor: AppColors.rosa, // Set background color to transparent
              foregroundColor: Colors.white, // Set foreground color to rosa
              child: const Icon(Icons.vertical_align_top), // Icon indicating upwards scrolling
              onPressed: () {
                _scrollToTop();
              },
            ),
          ),
          Positioned(
            bottom: 16, // Adjust the position as needed
            right: 16, // Adjust the position as needed
            child: FloatingActionButton(
              heroTag: 'vertical_align_bottom',
              mini: true, // Makes the button smaller
              backgroundColor: AppColors.rosa, // Set background color to transparent
              foregroundColor: Colors.white,
              child: const Icon(Icons.vertical_align_bottom), // Icon for the button
              onPressed: () {
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0, // Scroll to the top
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
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
            Text(
              'Low Stock Items',
              style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 200.0, // Set a fixed height for the scrollable area
              child: SingleChildScrollView(
                child: Column(
                  children: lowStockItems.map((item) {
                    return _buildLowStockItemCard(item);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockItemCard(Item item) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: AppColors.pink,
      child: ListTile(
        title: Row(
          children: [
            Text(
              '${item.name} - Quantity: ',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            _buildCircle(item.quantity.toString()), // Place the circle here
            const SizedBox(width: 4.0), // Add some space between the circle and the button
            _buildUpdateItemButton(context, item),
            const SizedBox(width: 4.0), // Add some space between the circle and the button
            _buildDeleteItemButton(context, item),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDescriptionText('Vendor:', item.vendor),
            _buildDescriptionText('Description:', item.description),
            _buildDescriptionText('Color:', item.color),
            _buildDescriptionText('Size:', item.size ?? 'N/A'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  void _showUpdateQuantityDialog(BuildContext context, Item item) {
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              'Update Quantity',
              style: TextStyle(color: AppColors.rosa)
          ), // Change text color to rosa
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'New Quantity',
              labelStyle: const TextStyle(color: AppColors.pink), // Customize label text color
              fillColor: Colors.white, // Fill color of the text field
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none, // No border
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border when focused
                borderRadius: BorderRadius.circular(30.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border for error
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border for error when focused
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update quantity in Firebase
                String quantityText = quantityController.text.trim();
                if (quantityText.isEmpty || quantityText == '0') {
                  Navigator.of(context).pop(); // Close the dialog
                  helper.showSnackBar(
                      'Quantity cannot be empty or zero. Please enter a valid number',
                      "Error", ScaffoldMessenger.of(context));
                  return;
                }

                int? newQuantity = int.tryParse(quantityText);
                if (newQuantity == null) {
                  Navigator.of(context).pop(); // Close the dialog
                  helper.showSnackBar(
                      'Invalid quantity. Please enter a valid number.',
                      "Error", ScaffoldMessenger.of(context));
                  return;
                }
                item.quantity += newQuantity;
                Map<String, String> result = await firestoreService.updateItem(item, item.id!);
                if (result['status'] == 'Error') {
                  Navigator.of(context).pop(); // Close the dialog
                  helper.showSnackBar(
                      "Updating Quantity failed! ${result['message']}",
                      "Error", ScaffoldMessenger.of(context));
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  helper.showSnackBar(
                      'Quantity successfully updated to ${item.quantity}!',
                      "Success", ScaffoldMessenger.of(context));
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpdateItemButton(BuildContext context, Item item) {
    return Container(
      width: 30, // Diameter of the circle
      height: 30, // Diameter of the circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.rosa, // Color of the circle
      ),
      child: Center(
        child: IconButton(
          padding: EdgeInsets.zero, // Remove padding
          icon: Icon(Icons.add),
          color: Colors.black,
          onPressed: () {
            _showUpdateQuantityDialog(context, item);
          },
        ),
      ),
    );
  }

  Widget _buildDeleteItemButton(BuildContext context, Item item) {
    return Container(
      width: 30, // Diameter of the circle
      height: 30, // Diameter of the circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.rosa, // Color of the circle
      ),
      child: Center(
        child: IconButton(
          padding: EdgeInsets.zero, // Remove padding
          icon: const Icon(Icons.delete),
          color: Colors.black,
          onPressed: () {
            _deleteItem(context, item);
          },
        ),
      ),
    );
  }

  Widget _buildCircle(String quantity) {
    return Container(
      width: 30, // Diameter of the circle
      height: 30, // Diameter of the circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.rosa, // Color of the circle
      ),
      child: Center(
        child: Text(
          quantity,
          style: const TextStyle(
            color: Colors.white, // Color of the text inside the circle
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionText(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: label == 'Vendor:' ? AppColors.rosa : AppColors.pink,
        borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: label == 'Vendor:' ? AppColors.rosa : AppColors.rosa,
            width: 0.5, // Border width
          )
      ),
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: Text(
          '$label $value',
          style: GoogleFonts.lato(
            fontSize: 14,
            color: label == 'Vendor:' ? Colors.black : Colors.white,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.0,
          ),
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

  void _deleteItem(BuildContext context, Item item) async {
    Map<String, String> result = await firestoreService.deleteItem(item.id!);
    if (result['status'] == 'Error') {
      if (mounted) {
        helper.showDialogBox(
            context, "Deleting Item failed!", result['message']!);
      }
    } else {
      if (mounted) {
        helper.showSnackBar('Item deleted successfully!', "Success",
            ScaffoldMessenger.of(context), duration: 2);
      }
    }
  }
}
