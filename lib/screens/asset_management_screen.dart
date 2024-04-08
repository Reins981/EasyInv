import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../trading/charts.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({Key? key}) : super(key: key);

  @override
  _AssetManagementScreenState createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final FirestoreService firestoreService = FirestoreService();
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
              _buildSearchBar(),
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
          title: Text(items[index].name),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusted alignment
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[index].vendor,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      items[index].description,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      items[index].size ?? 'N/A',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      items[index].color,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
                      ),
                    ),
                    // Add more subtitles as needed
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              const Expanded(child: TradingChart()),
              const SizedBox(width: 20.0),
              SizedBox(
                height: 40.0, // Adjust the height as needed
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(
                      color: Colors.red,
                      // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(4.0), // Border radius
                  ),
                  padding: const EdgeInsets.all(4.0),
                  // Add padding inside the box
                  child: Center(
                    child: Text(
                      '\$${items[index].buyingPrice}',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              SizedBox(
                height: 40.0, // Adjust the height as needed
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(
                      color: Colors.green,
                      // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(4.0), // Border radius
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    // Add padding inside the box
                    child: Center(
                      child: Text(
                        '\$${items[index].sellingPrice}',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

