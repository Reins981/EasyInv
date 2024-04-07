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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              double totalProfit = snapshot.data!.fold(0, (total, item) => total + item.profit);
              double chartHeight = calculateChartHeight(snapshot.data!);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalProfitWidget(totalProfit),
                    _buildStatCard('Total Items', totalItems),
                    const SizedBox(height: 20),
                    _buildStatCard('Total Categories', totalCategories),
                    const SizedBox(height: 20),
                    _buildLowStockItemsCard(lowStockItems),
                    const SizedBox(height: 20),
                    _buildInventoryChart(snapshot.data!, chartHeight),
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

  Widget _buildTotalProfitWidget(double totalProfit) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0), // Adjust margin as needed
      padding: EdgeInsets.all(8.0), // Add padding to give space around the text
      decoration: BoxDecoration(
        color: AppColors.rosa, // Background color of the rectangle
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$totalProfit', // Total profit formatted as currency with $ sign
            style: const TextStyle(
              fontSize: 30.0, // Customize font size
              fontWeight: FontWeight.bold, // Add bold font weight
              color: Colors.white, // Text color
              fontFamily: 'Roboto', // Customize font family if needed
              letterSpacing: 1.0, // Add letter spacing
            ),
          ),
          const Icon(
            Icons.attach_money, // Dollar sign icon
            color: Colors.white, // Icon color
            size: 30.0, // Customize size
          ),
        ],
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
                scrollDirection: Axis.vertical,
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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.rosa,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              content: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.pink,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        color: AppColors.pink,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              ListTile(
                title: Text(
                  item.name.length > 20 ? '${item.name.substring(0, 20)}...' : item.name,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
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
              Positioned(
                top: 0,
                right: 0,
                child: _buildCircle(item.quantity.toString()),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: [
                    _buildUpdateItemButton(context, item),
                    const SizedBox(width: 4.0), // Add some space between the buttons
                    _buildDeleteItemButton(context, item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            helper.handleItemUpdateQuantityWithDialog(context, item, firestoreService);
          },
        ),
      ),
    );
  }

  Widget _buildDeleteItemButton(BuildContext context, Item item) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.delete),
      color: Colors.black,
      onPressed: () {
        helper.handleItemDeleteWithDialog(context, item, _deleteItem);
      },
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

  double calculateChartHeight(List<Item> items) {
    // Adjust this multiplier based on your preference
    double itemHeight = 60.0;
    int itemCount = items.length;
    // Calculate the total height based on the number of items
    double totalHeight = itemCount * itemHeight;
    // Add extra padding or spacing as needed
    double paddingHeight = 100.0;
    // Return the total height plus padding
    return totalHeight + paddingHeight;
  }

  Widget _buildInventoryChart(List<Item> items, double chartHeight) {
    items.sort((a, b) => a.vendor.compareTo(b.vendor));
    final data = [
      charts.Series<Item, String>(
        id: 'Inventory',
        domainFn: (Item item, _) => _buildDomainText(item),
        measureFn: (Item item, _) => item.quantity,
        data: items,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.pink),
      ),
    ];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Set vertical scrolling
          child: SizedBox(
            height: chartHeight,
            child: charts.BarChart(
              data,
              animate: true,
              vertical: false, // Set vertical to false for horizontal orientation
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: const charts.OrdinalAxisSpec(
                  renderSpec: charts.NoneRenderSpec()),
            ),
          ),
        ),
      ),
    );
  }

  String _buildDomainText(Item item) {
    return '${_buildVendorText(item.vendor)} '
        '- ${item.name.length > 20 ? "${item.name.substring(0, 20)}...": item.name} '
        '- ${item.description.length > 20 ? "${item.description.substring(0, 20)}...": item.description} '
        '- ${item.color} '
        '- ${item.size ?? "N/A"} '
        '- (${item.quantity})';
  }

  String _buildVendorText(String vendor) {
    return vendor.length > 20 ? '${vendor.substring(0, 20)}...' : vendor;
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (result['status'] == 'Error') {
      if (mounted) {
        helper.showDialogBox(
            context, "Deleting Item failed!", result['message']!);
      }
    } else {
      if (scaffoldMessenger.mounted) {
        helper.showSnackBar('Item deleted successfully!', "Success",
            scaffoldMessenger, duration: 2);
      }
    }
  }
}
