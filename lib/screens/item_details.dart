import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../trading/charts.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;
  final Helper helper;
  final FirestoreService firestoreService = FirestoreService();

  ItemDetailScreen({
    super.key,
    required this.item,
    required this.helper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: AppColors.rosa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag, size: 50, color: AppColors.pink),
                const SizedBox(width: 10),
                Text(
                  item.category,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCombinedDetailCard([
                  {'title': 'Name', 'value': item.name},
                  {'title': 'Vendor', 'value': item.vendor},
                  {'title': 'Description', 'value': item.description},
                ]),
                const SizedBox(width: 10),
                _buildCombinedDetailCard([
                  {'title': 'Color', 'value': item.color},
                  {'title': 'Size', 'value': item.size ?? 'N/A'},
                  {'title': 'Quantity', 'value': item.quantity.toString()},
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.rosa.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TradingChart(itemId: item.id!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: _buildActionButton(
                    context,
                    'Add',
                    Icons.add,
                    AppColors.rosa,
                    AppColors.white,
                        () {
                          helper.handleItemUpdateQuantityWithDialog(context, item, firestoreService);
                    },
                  ),
                ),
                Flexible(
                  child: _buildActionButton(
                    context,
                    'Sell',
                    Icons.remove,
                    AppColors.pink,
                    AppColors.white,
                        () {
                          helper.handleItemSaleWithDialog(context, item, firestoreService);
                    },
                  ),
                ),
                Flexible(
                  child: _buildActionButton(
                    context,
                    'Delete',
                    Icons.delete,
                    Colors.black,
                    AppColors.white,
                        () {
                          helper.handleItemDeleteWithDialog(context, item, firestoreService);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color foregroundColor, Color backgroundColor, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
      icon: Icon(icon, size: 28, color: foregroundColor),
      label: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCombinedDetailCard(List<Map<String, String>> details) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: details.map((detail) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail['title']!,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    detail['value']!,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


