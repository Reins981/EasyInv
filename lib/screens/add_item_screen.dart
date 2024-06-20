import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../formatters/custom.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../utils/ocr_utils.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final Helper helper = Helper();
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _buyingController = TextEditingController();
  final TextEditingController _sellingController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final OCRUtils ocr = OCRUtils();
  String _selectedCategory = 'Ropa'; // Track the selected category
  String? _selectedSize = 'S'; // Track the selected size
  String _selectedColor = 'rojo'; // Track the selected size
  bool enterYourOwnSelected = false; // Track if "Enter your own" is selected

  // Categories to populate the dropdown menu
  final List<String> categories = [
    'Ropa',
    'Electrónica',
    'Papelería',
    // Add more categories as needed
  ];

  // Categories to populate the dropdown menu
  final List<String> sizes = [
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ];

  List<String> colorNames = [
    'agua',
    'ámbar',
    'amarillo',
    'azul',
    'azul marino',
    'azul cielo',
    'blanco',
    'cian',
    'coral',
    'fucsia',
    'granate',
    'gris',
    'índigo',
    'lavanda',
    'lima',
    'marrón',
    'magenta',
    'morado',
    'naranja',
    'negro',
    'oliva',
    'orquídea',
    'oro',
    'perú',
    'plata',
    'rojo',
    'rosa',
    'salmón',
    'turquesa',
    'verde',
    'verde azulado',
    'violeta'
  ];

  Map<String, List<dynamic>> itemData = {};
  List<String> itemNames = []; // List to store item names for suggestions
  List<String> itemDescriptions = []; // List to store item descriptions for suggestions
  List<String> itemVendor = []; // List to store item vendor for suggestions
  List<double> itemBuyingPrice = []; // List to store item buying price for suggestions
  List<double> itemSellingPrice = []; // List to store item selling price for suggestions
  List<int> itemQuantity = []; // List to store item quantity for suggestions

  @override
  void initState() {
    super.initState();
    // Fetch item names and descriptions for suggestions
    _fetchItemSuggestions().then((_) {
      setState(() {});
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _fetchItemSuggestions() async {
    // Fetch item names and descriptions based on selected category
    print("Fetching suggestions for $_selectedCategory...");
    itemData = await firestoreService.getItemDataByCategory(_selectedCategory);
    itemNames = itemData['names'] as List<String>;
    itemNames = itemNames.toSet().toList(); // Remove duplicates
    itemDescriptions = itemData['descriptions'] as List<String>;
    itemDescriptions = itemDescriptions.toSet().toList(); // Remove duplicates
    itemVendor = itemData['vendors'] as List<String>;
    itemVendor = itemVendor.toSet().toList(); // Remove duplicates
    itemBuyingPrice = itemData['buyingPrices'] as List<double>;
    itemBuyingPrice = itemBuyingPrice.toSet().toList(); // Remove duplicates
    itemSellingPrice = itemData['sellingPrices'] as List<double>;
    itemSellingPrice = itemSellingPrice.toSet().toList(); // Remove duplicates
    itemQuantity = itemData['quantities'] as List<int>;
    itemQuantity = itemQuantity.toSet().toList(); // Remove duplicates
    enterYourOwnSelected = false;
    print("itemSuggestions: $itemNames, $itemDescriptions, $itemVendor, $itemBuyingPrice, $itemSellingPrice, $itemQuantity");
  }

  void _clearItemSuggestions() {
    itemNames.clear();
    itemDescriptions.clear();
    itemVendor.clear();
    itemBuyingPrice.clear();
    itemSellingPrice.clear();
    itemQuantity.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agregar Artículo',
          style: GoogleFonts.lato(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
        leading: IconButton(
          onPressed: () {
            _clearItemSuggestions();
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      extendBody: true, // Extend body behind the AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  children: [
                    _buildDropdownField('Categoría del Artículo', categories),
                    _buildDropdownFieldWithSuggestions('Nombre del Artículo', itemNames, _nameController),
                    _buildDropdownFieldWithSuggestions('Descripción del Artículo', itemDescriptions, _descriptionController, multiline: true),
                    _buildDropdownField('Color del Artículo', colorNames, type: 'color'),
                    // Additional fields based on category
                    _buildDropdownField('Tamaño del Artículo', sizes, type: 'size'),
                    _buildDropdownFieldWithSuggestions('Proveedor del Artículo', itemVendor, _vendorController),
                    _buildDropdownFieldWithSuggestions('Precio de compra del artículo', itemBuyingPrice, _buyingController, doubleOnly: true),
                    _buildDropdownFieldWithSuggestions('Precio de venta del artículo', itemSellingPrice, _sellingController, doubleOnly: true),
                    _buildDropdownFieldWithSuggestions('Cantidad de artículos', itemQuantity, _quantityController, integerOnly: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _addItem();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.rosa,
                        backgroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        'Agregar Artículo',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          color: AppColors.rosa,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _clearTextFields([
                          _nameController,
                          _vendorController,
                          _descriptionController,
                          _buyingController,
                          _sellingController,
                          _quantityController,]);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.rosa,
                        backgroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      child: Text(
                        'Borrar campos de texto',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          color: AppColors.rosa,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ocr.processImage().then((value) {
            if (value.isNotEmpty) {
              List<TextEditingController> controllers = [
                _nameController,
                _descriptionController,
                _vendorController,
                _buyingController,
                _sellingController,
                _quantityController,
              ];

              setState(() {
                _clearTextFields(controllers);
                enterYourOwnSelected = true;
                for (int i = 0; i < controllers.length && i < value.length; i++) {
                  controllers[i].text = controllers[i] == _nameController || controllers[i] == _descriptionController || controllers[i] == _vendorController
                      ? value[i].toString()
                      : !isIntegerOrDouble(value[i]) ? 0.toString()
                      : value[i].toString();
                  print("Text $i: ${controllers[i].text}");
                }
              });
            } else {
              helper.showSnackBar('¡No se detectó ningún texto en la imagen!', "Error", ScaffoldMessenger.of(context));
            }
          });
        },
        tooltip: 'Capturar Imagen',
        backgroundColor: AppColors.rosa,
        foregroundColor: Colors.white,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildDropdownField(String labelText, List<String> items, {String type='category'}) {
    // Check if the type is 'size' and the selected category is 'Clothes'
    if (type == 'size' && _selectedCategory != 'Ropa') {
      // Return an empty container if the category is not 'Clothes'
      _selectedSize = null;
      return Container();
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: type == 'category'
            ? _selectedCategory
            : type == 'size'
            ? _selectedSize
            : _selectedColor,
          onChanged: (value) async {
            if (type == 'category') {
              _selectedCategory = value!;
              _clearTextFields([
                _nameController,
                _vendorController,
                _descriptionController,
                _buyingController,
                _sellingController,
                _quantityController,]);
              await _fetchItemSuggestions();
            } else if (type == 'size') {
              _selectedSize = value!;
            } else {
              _selectedColor = value!;
            }
            setState(() {});
          },
          decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: AppColors.pink),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList()
      ),
    );
  }

  Widget _buildTextField(
      String labelText,
      TextEditingController controller,
      {bool integerOnly = false, bool doubleOnly = false, bool multiline = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withOpacity(0.2), // Transparent pink shadow
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: integerOnly ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.multiline,
        inputFormatters: integerOnly ? [CustomInputFormatter(intOnly: true)] : doubleOnly ? [CustomInputFormatter(intOnly: false)] : null, // Restrict input to digits if integerOnly
        maxLines: multiline ? null : 1, // Set maxLines to null for multiline input
        decoration: InputDecoration(
          labelText: labelText,
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
          suffixIcon: Ink(
            decoration: const ShapeDecoration(
              color: Colors.transparent, // Customize the ink color to pink
              shape: CircleBorder(),
            ),
            child: InkWell(
              onTap: () {
                controller.clear();
              },
              splashColor: Colors.transparent, // Set splash color to transparent
              child: const Icon(
                Icons.clear,
                color: Colors.pink,
              ),
            ),
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Por favor, ingrese $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFieldWithSuggestions(
      String labelText,
      List<dynamic> suggestions,
      TextEditingController controller, {
        bool multiline = false,
        bool integerOnly = false,
        bool doubleOnly = false,
      }) {
    if (suggestions.isEmpty || enterYourOwnSelected) {
      return _buildTextField(labelText, controller, multiline: multiline, integerOnly: integerOnly, doubleOnly: doubleOnly);
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: null, // Set value to null to indicate that no item is selected
          onChanged: (value) {
            setState(() {
              if (value != null && value == '') {
                enterYourOwnSelected = true;
              } else if (value == null) {
                enterYourOwnSelected = false;
                controller.clear(); // Clear the controller's value
              } else {
                // Update the controller with the selected value
                controller.text = value;
                enterYourOwnSelected = false;
              }
            });
          },
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: AppColors.pink),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          items: [
            ...suggestions.map((dynamic suggestion) {
              return DropdownMenuItem<String>(
                value: suggestion.toString(),
                child: SizedBox( // Wrap the child in a SizedBox to set a maximum width
                  width: 200, // Adjust width as needed
                  child: Text( // Limit the text length to avoid overflow
                    suggestion.toString().length > 20 ? "${suggestion.toString().substring(0, 20)}..." : suggestion.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
            const DropdownMenuItem<String>(
              value: '',
              child: Text('Ingrese el suyo'),
            ),
          ],
        ),
      );
    }
  }

  void _clearTextFields(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.clear();
    }
  }

  bool anyControllerEmpty(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        return true; // Return true if any controller has an empty string
      }
    }
    return false; // Return false if all controllers have non-empty strings
  }


  Future<void> _addItem() async {
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      if (anyControllerEmpty([
        _nameController,
        _vendorController,
        _descriptionController,
        _buyingController,
        _sellingController,
        _quantityController,
      ])) {
        helper.showSnackBar('¡Por favor complete todos los campos!', "Error", scaffoldMessenger);
        return;
      }
      final newItem = Item(
        category: _selectedCategory,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        size: _selectedSize,
        color: _selectedColor,
        vendor: _vendorController.text.trim(),
        buyingPrice: double.parse(_buyingController.text.trim()),
        sellingPrice: double.parse(_sellingController.text.trim()),
        quantity: int.parse(_quantityController.text.trim()),
        profit: 0.toDouble(),
        totalQuantitySold: 0,
      );
      // Check if a product with identical field values (except for quantity) already exists
      final Map<String, dynamic> result = await firestoreService.getItemByFields(newItem);
      final existingProduct = result['item'] as Item?;
      final productId = result['itemId'] as String?;
      final status = result['status'] as String;

      if (status != 'Success') {
        helper.showDialogBox(context, "Error", status);
        return;
      }
      if (existingProduct != null) {
        // Update quantity of existing product
        existingProduct.quantity += newItem.quantity;
        Map<String, String> result = await firestoreService.updateItem(existingProduct, productId!);
        if (result['status'] == 'Error') {
          if (mounted) {
            helper.showDialogBox(
                context, "¡Falló la actualización de la cantidad!", result['message']!);
          }
        } else {
          if (mounted) {
            helper.showSnackBar('Cantidad actualizada correctamente a ${existingProduct.quantity}!', "Success",
                scaffoldMessenger, duration: 2);
          }
        }
      } else {
        // Add new product to Firebase
        Map<String, String> result = await firestoreService.addItem(newItem);
        if (result['status'] == 'Error') {
          if (mounted) {
            helper.showDialogBox(
                context, "¡Error al añadir el artículo!", result['message']!);
          }
        } else {
          if (mounted) {
            helper.showSnackBar('¡Artículo añadido correctamente!', "Success",
                scaffoldMessenger, duration: 2);
          }
        }
      }
    } else {
      helper.showSnackBar('¡Por favor complete todos los campos!', "Error", scaffoldMessenger);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vendorController.dispose();
    _descriptionController.dispose();
    _buyingController.dispose();
    _sellingController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  bool isIntegerOrDouble(value) {
    return int.tryParse(value) != null || double.tryParse(value) != null;
  }
}
