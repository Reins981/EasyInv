  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
  import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';

  class LowStockItemWidget extends StatefulWidget {
    final List<Item> items;

    const LowStockItemWidget({super.key,
      required this.items
    });

    @override
    _LowStockItemWidgetState createState() => _LowStockItemWidgetState();
  }

  class _LowStockItemWidgetState extends State<LowStockItemWidget> {
    final TextEditingController _searchController = TextEditingController();
    final ValueNotifier<String> _searchText = ValueNotifier<String>('');
    final Helper helper = Helper();
    final FirestoreService firestoreService = FirestoreService();
    List<Item>? filteredItems;

    @override
    void initState() {
      _searchText.addListener(_filterItems);
      super.initState();
    }

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return _buildLowStockItemsCard(widget.items);
    }

    void _filterItems() {
      final searchText = _searchText.value.toLowerCase();
      filteredItems = widget.items.where((item) =>
      item.name.toLowerCase().contains(searchText) ||
          item.vendor.toLowerCase().contains(searchText) ||
          item.category.toLowerCase().contains(searchText)).toList();
      setState(() {});
    }

    void _clearSearch() {
      _searchController.clear();
      _searchText.value = '';
      filteredItems = null;
      setState(() {});
    }

    Widget _buildLowStockItemsCard(List<Item> items) {
      filteredItems ??= items;
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
              Row(
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
                            icon: const Icon(
                                Icons.clear,
                                color: AppColors.pink
                            ), // Set clear icon color
                            onPressed: () {
                              _clearSearch();
                            },
                          ),
                          suffixIconColor: AppColors.pink, // Set clear icon color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 200.0, // Set a fixed height for the scrollable area
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: filteredItems!.map((item) {
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
          helper.handleItemDeleteWithDialog(context, item, firestoreService);
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
  }
