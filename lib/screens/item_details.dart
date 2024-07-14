import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../trading/charts.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  final Helper helper;
  final FirestoreService firestoreService = FirestoreService();

  ItemDetailScreen({
    super.key,
    required this.item,
    required this.helper
  });

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

  class _ItemDetailScreenState extends State<ItemDetailScreen> with SingleTickerProviderStateMixin{

    late Item _item;
    late final AnimationController _animationController;
    late Animation<double> _animation;

    @override
    void initState() {
      super.initState();
      _item = widget.item;
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
      _animationController.dispose(); // Dispose the animation controller
      super.dispose();
    }

    void _addItem() {
      widget.helper.handleItemUpdateQuantityWithDialog(
          context,
          "Add",
          _item,
          widget.firestoreService,
          (updatedItem) {
            setState(() {
              _item = updatedItem;
            });
          }
      );
    }

    void _removeItem() {
      widget.helper.handleItemUpdateQuantityWithDialog(
          context,
          "Remove",
          _item,
          widget.firestoreService,
              (updatedItem) {
            setState(() {
              _item = updatedItem;
            });
          }
      );
    }

    void _updatePrice(String label) {
      widget.helper.handleItemUpdatePriceWithDialog(
          context,
          _item,
          label,
          widget.firestoreService,
              (updatedItem) {
            setState(() {
              _item = updatedItem;
            });
          }
      );
    }

    void _deleteItem() async {
      bool result = await widget.helper.handleItemDeleteWithDialog(
          context,
          _item,
          widget.firestoreService
      );
      if (mounted && result == true) {
        Navigator.pushReplacementNamed(context, '/asset_management');
      }
    }

    void _sellItem() {
      widget.helper.handleItemSaleWithDialog(
          context,
          _item,
          widget.firestoreService,
          (updatedItem) {
            setState(() {
              _item = updatedItem;
            });
          }
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_item.name),
          centerTitle: true,
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
                    _item.category,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pink,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_item.trend != null)
                    if (_item.trend == 'up')
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 30,
                      )
                    else if (_item.trend == 'down')
                      const Icon(
                        Icons.trending_down,
                        color: Colors.red,
                        size: 30,
                      )
                    else
                      const Icon(
                        Icons.trending_flat,
                        color: Colors.grey,
                        size: 30,
                      ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Tooltip(
                        message: 'Beneficio total',
                        child: _buildProfitButton(_item.profit)
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'Cambiar precio de compra',
                      child: _buildPriceButton(
                        _item.buyingPrice.toStringAsFixed(2),
                        "Buying Price",
                        Colors.red,
                        Colors.red,
                            (price) => _updatePrice(price),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'Cambiar precio de venta',
                      child: _buildPriceButton(
                        _item.sellingPrice.toStringAsFixed(2),
                        "Selling Price",
                        Colors.green,
                        Colors.green,
                            (price) => _updatePrice(price),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCombinedDetailCard([
                    {'title': 'Nombre', 'value': _item.name.length > 20 ? '${_item.name.substring(0, 20)}...' : _item.name},
                    {'title': 'Proveedor', 'value': _item.vendor.length > 20 ? '${_item.vendor.substring(0, 20)}...' : _item.vendor},
                    {'title': 'Descripción', 'value': _item.description.length  > 20 ? '${_item.description.substring(0, 20)}...' : _item.description},
                  ]),
                  const SizedBox(width: 10),
                  _buildCombinedDetailCard([
                    {'title': 'Color', 'value': _item.color},
                    {'title': 'Tamaño', 'value': _item.size ?? 'N/D'},
                    {'title': 'Cantidad', 'value': _item.quantity.toString()},
                  ]),
                ],
              ),
              const SizedBox(height: 20),
              _buildItemsQuantitySoldByClient(_item),
              const SizedBox(height: 20),
              /*Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.rosa.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TradingChart(
                    key: ValueKey(_item.quantity),
                    item: _item,
                    itemId: _item.id!,
                    firestoreService: widget.firestoreService
                ),
              ),
              const SizedBox(height: 20),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Add',
                      Icons.add,
                      AppColors.rosa,
                      AppColors.white,
                      _addItem,
                    ),
                  ),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Add',
                      Icons.remove,
                      AppColors.pink,
                      AppColors.white,
                      _removeItem,
                    ),
                  ),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Sell',
                      Icons.attach_money,
                      AppColors.pink,
                      AppColors.white,
                      _sellItem,
                    ),
                  ),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Delete',
                      Icons.delete,
                      Colors.black,
                      AppColors.white,
                      _deleteItem,
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
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        child: label == 'Sell' ?
        GradientIcon(
          icon: icon,
          gradientColors: [Colors.purpleAccent, Colors.pink], // Replace with your gradient colors
          size: 28,
        ) : Icon(icon, size: 28, color: foregroundColor),
      );
    }

    Widget _buildPriceButton(dynamic price, String label, Color foregroundColor, Color backgroundColor, Function(dynamic) onPressed) {
      return ElevatedButton(
        onPressed: () => onPressed(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor.withOpacity(0.2), // Foreground (text) color
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          elevation: 0
        ),
        child: Center(
          child: Text(
            '\$$price',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: foregroundColor,
            ),
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

    Widget _buildItemsQuantitySoldByClient(Item item) {
      // Get the total number of quantity for this item being sold
      int totalQuantitySold = item.totalQuantitySold;
      String currentMonth = DateFormat('MMMM').format(DateTime.now());
      String currentYear = DateFormat('yyyy').format(DateTime.now());
      return FutureBuilder<Map<String, Map<String, int>>>(
        future: widget.firestoreService.getItemQuantitySoldByClient(item),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
              ),
            );
          } else if (snapshot.hasError) {
            return widget.helper.showStatus('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return widget.helper.showStatus('No hay datos disponibles');
          } else {
            Map<String, Map<String, int>> data = snapshot.data!;
            List<Widget> itemList = [];

            itemList.add(
              ListTile(
                title: Text(
                  'Artículo: ${item.name}',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: AppColors.pink,
                  ),
                ),
                subtitle: Text(
                  'Cantidad total vendida: $totalQuantitySold',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.rosa,
                  ),
                ),
              ),
            );

            data.forEach((client, items) {
              items.forEach((itemName, quantitySold) {
                itemList.add(
                  ListTile(
                    title: Text(
                      'Cliente: $client',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: AppColors.pink,
                      ),
                    ),
                    subtitle: Text(
                      'Cantidad vendida: $quantitySold',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppColors.rosa,
                      ),
                    ),
                  ),
                );
              });
            });

            return Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              child: ExpansionTile(
                title: Text(
                  'Ventas por cliente\n$currentMonth $currentYear',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pink,
                  ),
                ),
                children: itemList,
              ),
            );
          }
        },
      );
    }

    Widget _buildProfitButton(dynamic profit) {
      return FutureBuilder<bool>(
        future: widget.firestoreService.salesDataExistForItem(_item.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ElevatedButton(
              onPressed: () {}, // You can provide a placeholder onPressed function if needed
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
              ),
            );
          } else if (snapshot.hasError) {
            return ElevatedButton(
              onPressed: () {}, // You can provide a placeholder onPressed function if needed
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Icon(Icons.error_outline, color: Colors.red),
            );
          } else {
            bool success = snapshot.data ?? false; // Default to false if snapshot.data is null

            // Reset relevant item attributes in case the sales data got deleted due to expiration
            // but the item had been sold in the past
            // Update state only if needed
            if (!success && profit != 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _item.profit = 0;
                  _item.totalQuantitySold = 0;
                });
                widget.firestoreService.updateItem(_item, _item.id!).then((_){});
              });
            }
            profit = profit.toDouble();
            profit = profit.toStringAsFixed(2);

            return ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,// Ensure the button itself is transparent to show the gradient
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                shadowColor: Colors.transparent, // Remove any shadow to maintain the gradient appearance
                elevation: 0, // Removes any elevation/shadow effect
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, AppColors.pink],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  constraints: BoxConstraints(minHeight: 36.0), // Adjust the minimum height as needed
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ScaleTransition(
                          scale: _animation,
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
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      );
    }
  }


