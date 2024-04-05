import 'package:easy_inv/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../utils/colors.dart';

// Define a custom input formatter to allow only digits or digits and a single dot
class CustomInputFormatter extends TextInputFormatter {
  bool intOnly = false;
  CustomInputFormatter({required this.intOnly});
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits and a single dot
    final regExp = intOnly ? RegExp(r'^(?!0$)\d*$') : RegExp(r'^\d*\.?\d*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    // Return the old value if the new value doesn't match the pattern
    return oldValue;
  }
}

class Helper {

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
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.pink,
          borderRadius: BorderRadius.circular(30.0),
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
          backgroundColor: AppColors.rosa,
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

  void handleItemDeleteWithDialog(BuildContext context, Item item, deleteFunction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.rosa,
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
              child: const Text(
                'No',
                style: TextStyle(color: AppColors.pink), // Customize color
              ),
            ),
            TextButton(
              onPressed: () {
                deleteFunction(context, item); // Call delete function
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: AppColors.pink), // Customize color
              ),
            ),
          ],
        );
      },
    );
  }

  void handleItemUpdateQuantityWithDialog(BuildContext context, Item item, FirestoreService firestoreService) {
    TextEditingController quantityController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
}