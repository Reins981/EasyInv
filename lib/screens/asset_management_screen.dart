import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../trading/charts.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({Key? key}) : super(key: key);

  @override
  _AssetManagementScreenState createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> with SingleTickerProviderStateMixin{
  final FirestoreService firestoreService = FirestoreService();
  final Helper helper = Helper();
  TextEditingController _searchController = TextEditingController();
  late final AnimationController _animationController;
  late Animation<double> _animation;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Adjust curve as needed
    );
    _animationController.forward(); // Start the animation
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Management'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Item>>(
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
                  Text(
                    'No items in inventory.',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!;
          items.sort((a, b) {
            // First, compare by vendor
            int vendorComparison = a.vendor.compareTo(b.vendor);
            if (vendorComparison != 0) {
              return vendorComparison;
            }

            // If vendors are equal, compare by category
            return a.category.compareTo(b.category);
          });
          return Column(
            children: [
              const SizedBox(height: 16.0),
              _buildSearchBar(),
              const SizedBox(height: 20.0),
              _buildSortingColumns(),
              Expanded(
                child: _buildItemList(items),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name, vendor, or category',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSortingColumns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSortColumn('Trending'),
        _buildSortColumn('Top Profits'),
        _buildSortColumn('A-Z'),
      ],
    );
  }

  Widget _buildSortColumn(String title) {
    return GestureDetector(
      onTap: () {
        // Implement sorting logic based on the column tapped
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(List<Item> items) {
    // Implement the list of items based on the search query and sorting criteria
    // This can be a ListView.builder or a custom widget depending on your data source
    return ListView.builder(
      itemCount: items.length, // Replace with the actual item count
      itemBuilder: (context, index) {
        // Build each item widget here
        return ListTile(
          leading: const Icon(Icons.shopping_bag),
          //title: _buildSubtitleHeader(items[index].name),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubtitleHeader(items[index].name),
                    _buildSubtitle(items[index].vendor),
                    _buildSubtitle(items[index].description),
                    _buildSubtitle(items[index].color),
                    _buildSubtitle(items[index].size ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TradingChart(),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceContainer(items[index].buyingPrice, Colors.red),
                    _buildPriceContainer(items[index].sellingPrice, Colors.green),
                    _buildProfitContainer(items[index].profit),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(String value) {
    return Text(
      value,
      style: GoogleFonts.lato(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSubtitleHeader(String value) {
    return Text(
      value,
      style: GoogleFonts.lato(
        fontSize: 14,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildPriceContainer(double price, Color color) {
    return SizedBox(
      height: 30.0,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: color,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Center(
          child: Text(
            '\$$price',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfitContainer(double profit) {
    return SizedBox(
      height: 30.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.pink],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: AppColors.rosa,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _animation, // Assuming _animation is defined in your State class
                    child: const Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '\$$profit',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSellButton(BuildContext context, Item item) {
    return ElevatedButton(
      onPressed: () {
       helper.handleItemSaleWithDialog(context, item, firestoreService);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.purpleAccent,
        backgroundColor: AppColors.rosa,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16.0),
        elevation: 4,
      ),
      child: const Icon(
        Icons.attach_money,
        color: Colors.purpleAccent,
        size: 30.0,
      ),
    );
  }
}

