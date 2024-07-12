import 'package:easy_inv/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../utils/colors.dart';


class Helper {

  Future<Map<String, dynamic>> getCurrentUserDetails({bool forceRefresh=false}) async {

    try {
      IdTokenResult idTokenResult = await getIdTokenResult(null, forceRefresh: forceRefresh);

      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      final userUid = user!.uid;
      final userEmail = user.email;
      final userName = user.displayName;

      final token = idTokenResult.token;

      return {
        'userUid': userUid,
        'userEmail': userEmail,
        'userName': userName,
        'token': token,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<IdTokenResult> getIdTokenResult(User? thisUser, {bool forceRefresh=false}) async {
    User? user = thisUser ?? FirebaseAuth.instance.currentUser;
    if (user == null) {

      String errorMessage = 'Usuario no ha iniciado sesión';
      throw Exception(errorMessage);
    }

    if (forceRefresh == true) {
      try {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        throw Exception(e);
      }
    }

    return await user!.getIdTokenResult();
  }

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
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cerrar',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
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
          title: Text(
            'Confirmar eliminación',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar este elemento?',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: Text(
                'No',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
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
              child: Text(
                'Si',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
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

  Future<void> validateAndSubmitPrice(BuildContext context, Item item, TextEditingController priceController, String label, FirestoreService firestoreService, ScaffoldMessengerState scaffoldMessenger) async {
    String priceText = priceController.text.trim();

    if (priceText.isEmpty || priceText == '0') {
      Navigator.of(context).pop(); // Close the dialog
      if (scaffoldMessenger.mounted) {
        showSnackBar(
            label == 'Buying Price'
                ? 'Precio de Compra no puede estar vacío ni ser cero. Por favor, ingrese un número válido.'
                : 'Precio de Venta no puede estar vacío ni ser cero. Por favor, ingrese un número válido.',
            "Error", scaffoldMessenger);
      }
      return;
    }

    // Regular expression to match a number with up to 3 decimal places
    final RegExp regex = RegExp(r'^\d*\.?\d{0,3}$');

    if (!regex.hasMatch(priceText)) {
      Navigator.of(context).pop(); // Close the dialog
      if (scaffoldMessenger.mounted) {
        showSnackBar(
            'El precio no puede tener más de tres posiciones después del punto decimal.',
            "Error", scaffoldMessenger);
      }
      return;
    }

    double? newPrice = double.tryParse(priceText);
    if (newPrice == null) {
      Navigator.of(context).pop(); // Close the dialog
      if (scaffoldMessenger.mounted) {
        showSnackBar(
            'El precio ingresado no es un número válido. Por favor, ingrese un número válido.',
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
            label == 'Buying Price'
                ? "Actualizando Precio de Compra falló! ${result['message']}"
                : "Actualizando Precio de Venta falló! ${result['message']}",
            "Error", scaffoldMessenger);
      }
    } else {
      Navigator.of(context).pop(); // Close the dialog
      if (scaffoldMessenger.mounted) {
        if (label == 'Buying Price') {
          showSnackBar(
              '$label actualizado correctamente a ${item.buyingPrice}!',
              "Success", scaffoldMessenger);
        } else {
          showSnackBar(
              '$label actualizado correctamente a ${item.sellingPrice}!',
              "Success", scaffoldMessenger);
        }
      }
    }
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
            label == 'Buying Price' ? 'Actualizar Precio de Compra': 'Actualizar Precio de Venta',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.rosa,
              letterSpacing: 1.0,
            ),
          ),
          // Change text color to rosa
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label == 'Buying Price' ? 'Precio de Compra nuevo': 'Precio de Venta nuevo',
              labelStyle: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.pink,
                letterSpacing: 1.0,
              ),
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
              child: Text(
                'Cancelar',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update quantity in Firebase
                validateAndSubmitPrice(context, item, priceController, label, firestoreService, scaffoldMessenger);
                  if (onItemUpdate != null) {
                    onItemUpdate(
                        item); // Call the callback with the updated item
                  }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: Text(
                'Actualización',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void handleItemUpdateQuantityWithDialog(
      BuildContext context, String mode, Item item, FirestoreService firestoreService, Function(Item)? onItemUpdate) {
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
          title: Text(
            'Actualizar cantidad',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.rosa,
              letterSpacing: 1.0,
            ),
          ), // Change text color to rosa
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Agregar cantidad',
              labelStyle:  GoogleFonts.lato(
                fontSize: 16,
                color: Colors.pink,
                letterSpacing: 1.0,
              ), // Customize label text color
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
              child: Text(
                'Cancelar',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update quantity in Firebase
                String quantityText = quantityController.text.trim();
                if (quantityText.isEmpty || quantityText == '0') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'No se puede dejar vacío ni poner cero en la cantidad. Por favor, introduzca un número válido.',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }

                int? newQuantity = int.tryParse(quantityText);
                if (newQuantity == null) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Cantidad no válida. Por favor, ingrese un número válido.',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }
                if (mode == "Remove" && newQuantity > item.quantity) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Cantidad no válida. No puedes eliminar más artículos de los que tienes',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }
                mode == "Add" ? item.quantity += newQuantity : item.quantity -= newQuantity;
                Map<String, String> result = await firestoreService.updateItem(item, item.id!);
                if (result['status'] == 'Error') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        "¡Fallo al actualizar la cantidad! ${result['message']}",
                        "Error", scaffoldMessenger);
                  }
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Cantidad actualizada correctamente a ${item.quantity}!',
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
              child: Text(
                'Actualización',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void handleItemSaleWithDialog(BuildContext context, Item item, FirestoreService firestoreService, Function(Item) onItemSale) {
    TextEditingController saleController = TextEditingController();
    TextEditingController clienteController = TextEditingController();
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
            'Venta del artículo',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.rosa,
              letterSpacing: 1.0,
            ),
          ), // Change text color to rosa
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: saleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '¿Cuántos artículos se han vendido?',
                  labelStyle: GoogleFonts.lato(
                    fontSize: 16,
                    color: AppColors.pink,
                    letterSpacing: 1.0,
                  ), // Customize label text color
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
              const SizedBox(height: 16.0), // Space between TextFields
              TextField(
                controller: clienteController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Cliente',
                  labelStyle: GoogleFonts.lato(
                    fontSize: 16,
                    color: AppColors.pink,
                    letterSpacing: 1.0,
                  ), // Customize label text color
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
            ],
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
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update quantity in Firebase
                String numItemsSold = saleController.text.trim();
                if (numItemsSold.isEmpty || numItemsSold == '0') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'El número de artículos vendidos no puede estar vacío ni ser cero. Por favor, ingrese un número válido.',
                        "Error", scaffoldMessenger);
                  }
                  return;
                }

                int? numItemsSoldInt = int.tryParse(numItemsSold);
                if (numItemsSoldInt == null) {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        'Venta inválida. Por favor, ingrese un número válido..',
                        "Error", scaffoldMessenger);
                  }
                  return;
                } else {
                  if (numItemsSoldInt > item.quantity) {
                    Navigator.of(context).pop(); // Close the dialog
                    if (scaffoldMessenger.mounted) {
                      showSnackBar(
                          'No se pueden vender más artículos de los ${item.quantity} disponibles.',
                          "Error", scaffoldMessenger);
                    }
                    return;
                  }
                }

                // Update the new quantity, profit and client in Firebase
                String client = clienteController.text.trim();
                client = client.isEmpty ? 'Cliente no especificado' : client;
                Map<String, String> resultSale = await item.recordSale(numItemsSoldInt, client);
                if (resultSale['status'] == 'Error') {
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    showSnackBar(
                        "¡Fallo en la venta del artículo! ${resultSale['message']}",
                        "Error", scaffoldMessenger);
                  }
                } else {
                  onItemSale(item);  // Call the callback with the updated item
                  Navigator.of(context).pop(); // Close the dialog
                  if (scaffoldMessenger.mounted) {
                    item.sellingPrice > item.buyingPrice ? showSnackBar(
                        '¡Venta del artículo exitosa! Nuevo beneficio: ${item.profit}!',
                        "Success", scaffoldMessenger
                    )
                        : showSnackBar(
                        '¡Venta del artículo exitosa pero estabas vendiendo con pérdida!',
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
              child: Text(
                'Vender',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppColors.pink,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}