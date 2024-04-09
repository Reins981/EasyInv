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
  final ValueNotifier<String> _searchText = ValueNotifier('');

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

  void _clearSearch() {
    _searchController.clear();
    _searchText.value = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Management'),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
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
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.rosa, // Set background color
              borderRadius: BorderRadius.circular(30.0), // Set border radius
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _searchText.value = value,
              style: const TextStyle(color: Colors.black), // Set text color
              cursorColor: AppColors.pink,
              decoration: InputDecoration(
                labelText: 'Search by Vendor, Name, or Category',
                labelStyle: const TextStyle(color: AppColors.pink),
                prefixIcon: const Icon(Icons.search, color: Colors.white), // Set icon color
                border: InputBorder.none, // Remove border
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.pink), // Set clear icon color
                  onPressed: () {
                    _clearSearch();
                  },
                ),
                suffixIconColor: AppColors.pink,
              ),
            ),
          ),
        ),
      ],
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
          color: AppColors.pink,
          border: Border.all(color: AppColors.pink),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
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
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(
              items[index].name,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        value = value.length > 8 ? '${value.substring(0, 8)}...' : value
        style: GoogleFonts.lato(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.0,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildPriceContainer(dynamic price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          '\$$price',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProfitContainer(dynamic profit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purpleAccent, AppColors.pink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ScaleTransition(
              scale: _animation, // Assuming _animation is defined in your State class
              child: const Icon(
                Icons.attach_money,
                color: Colors.white,
                size: 14.0,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                '$profit',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
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
