import 'package:easy_inv/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../utils/colors.dart';


class Helper {

  double calculateProfit(double buyingPrice, double sellingPrice, int quantity) {
    return sellingPrice > buyingPrice
        ? (sellingPrice - buyingPrice) * quantity
        : 0;
  }

  void showSnackBar(String message, String messageType,
      ScaffoldMessengerState context, {int duration = 4}) {
    Color backgroundColor = messageType == "Error" ? AppColors.pink : AppColors.rosa;

    context.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: duration),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.all(10),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Center showStatus(String status) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.pink,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          status,
          style: GoogleFonts.lato(
            fontSize: 10,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  void showDialogBox(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
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
  }

  Future<bool> handleItemDeleteWithDialog(BuildContext context, Item item, FirestoreService firestoreService) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: const Text(
                'No',
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(item, firestoreService); // Call delete function
                Navigator.of(context).pop(); // Close the dialog
                result = true;
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: const Text(
                'Yes',
              ),
            ),
          ],
        );
      },
    );
    return result;
  }

  void _deleteItem(Item item, FirestoreService firestoreService) async {
    await firestoreService.deleteItem(item.id!);
  }

  void handleItemUpdatePriceWithDialog(
      BuildContext context,
      Item item,
      String label,
      FirestoreService firestoreService,
      Function(Item)? onItemUpdate) {
    TextEditingController priceController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: Text(
              'Update $label',
              style: const TextStyle(color: AppColors.rosa)
          ),
          // Change text color to rosa
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'New $label',
              labelStyle: const TextStyle(color: AppColors.pink),
              // Customize label text color
              fillColor: AppColors.rosa,
              // Fill color of the text field
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
                String priceText = priceController.text.trim();
                if (priceText.isEmpty || priceText == '0') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        '$label cannot be empty or zero. Please enter a valid number',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }

                int? newPrice = int.tryParse(priceText);
                if (newPrice == null) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Invalid $label. Please enter a valid number.',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }

                if (label == 'Buying Price') {
                  item.buyingPrice = newPrice;
                } else {
                  item.sellingPrice = newPrice;
                }

                Map<String, String> result = await firestoreService.updateItem(
                    item, item.id!);
                if (result['status'] == 'Error') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        "Updating $label failed! ${result['message']}",
                        "Error", scaffoldMessenger);
                  }
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    if (label == 'Buying Price') {
                      showSnackBar(
                          '$label successfully updated to ${item.buyingPrice}!',
                          "Success", scaffoldMessenger);
                    } else {
                      showSnackBar(
                          '$label successfully updated to ${item.sellingPrice}!',
                          "Success", scaffoldMessenger);
                    }
                  }
                  if (onItemUpdate != null) {
                    onItemUpdate(
                        item); // Call the callback with the updated item
                  }
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

  void handleItemUpdateQuantityWithDialog(BuildContext context, Item item, FirestoreService firestoreService, Function(Item)? onItemUpdate) {
    TextEditingController quantityController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: const Text(
              'Update Quantity',
              style: TextStyle(color: AppColors.rosa)
          ), // Change text color to rosa
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Add Quantity',
              labelStyle: const TextStyle(color: AppColors.pink), // Customize label text color
              fillColor: AppColors.rosa, // Fill color of the text field
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
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Quantity cannot be empty or zero. Please enter a valid number',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }

                int? newQuantity = int.tryParse(quantityText);
                if (newQuantity == null) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Invalid quantity. Please enter a valid number.',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }
                item.quantity += newQuantity;
                Map<String, String> result = await firestoreService.updateItem(item, item.id!);
                if (result['status'] == 'Error') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        "Updating Quantity failed! ${result['message']}",
                        "Error", scaffoldMessenger);
                  }
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Quantity successfully updated to ${item.quantity}!',
                        "Success", scaffoldMessenger);
                  }
                  if (onItemUpdate != null) {
                    onItemUpdate(item); // Call the callback with the updated item
                  }
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

  void handleItemSaleWithDialog(BuildContext context, Item item, FirestoreService firestoreService, Function(Item) onItemSale) {
    TextEditingController saleController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: const Text(
              'Item sale',
              style: TextStyle(color: AppColors.rosa)
          ), // Change text color to rosa
          content: TextField(
            controller: saleController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'How many items have been sold?',
              labelStyle: const TextStyle(color: AppColors.pink), // Customize label text color
              fillColor: AppColors.rosa, // Fill color of the text field
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
                String numItemsSold = saleController.text.trim();
                if (numItemsSold.isEmpty || numItemsSold == '0') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Number of items sold cannot be empty or zero. Please enter a valid number',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }

                int? numItemsSoldInt = int.tryParse(numItemsSold);
                if (numItemsSoldInt == null) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Invalid sale. Please enter a valid number.',
                        "Error", scaffoldMessenger);
                  }
                  return;
                } else {
                  if (numItemsSoldInt > item.quantity) {
                    Navigator.of(context).pop(); // Close the dialog
                    if (scaffoldMessenger.mounted) {
                      showSnackBar(
                          'Number of items sold cannot be more than the available quantity ${item.quantity}',
                          "Error", scaffoldMessenger);
                    }
                    return;
                  }
                }

                // Update the new quantity and profit in Firebase
                Map<String, String> resultSale = await item.recordSale(numItemsSoldInt);
                if (resultSale['status'] == 'Error') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        "Item sale failed! ${resultSale['message']}",
                        "Error", scaffoldMessenger);
                  }
                } else {
                  onItemSale(item);  // Call the callback with the updated item
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    item.sellingPrice > item.buyingPrice ? showSnackBar(
                        'Item sale success! New profit: ${item.profit}!',
                        "Success", scaffoldMessenger
                    )
                        : showSnackBar(
                        'Item sale success but you were selling with a loss!',
                        "Success",
                        scaffoldMessenger
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: const Text('Sell'),
            ),
          ],
        );
      },
    );
  }
}