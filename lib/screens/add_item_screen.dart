import 'dart:ffi';

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';

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
  String _selectedCategory = 'Clothes'; // Track the selected category
  String? _selectedSize = 'S'; // Track the selected size
  String _selectedColor = 'red'; // Track the selected size
  bool enterYourOwnSelected = false; // Track if "Enter your own" is selected

  // Categories to populate the dropdown menu
  final List<String> categories = [
    'Clothes',
    'Electronics',
    'Stationery',
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
    'red',
    'green',
    'blue',
    'yellow',
    'orange',
    'purple',
    'teal',
    'cyan',
    'brown',
    'amber',
    'indigo',
    'lime',
    'grey',
    'pink',
    'black',
    'white',
    'silver',
    'gold',
    'maroon',
    'navy',
    'olive',
    'fuchsia',
    'aqua',
    'violet',
    'magenta',
    'turquoise',
    'coral',
    'salmon',
    'lavender',
    'peru',
    'orchid',
    'skyBlue',
  ];

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
    _fetchItemSuggestions();
  }

  Future<void> _fetchItemSuggestions() async {
    // Fetch item names and descriptions based on selected category
    print("Fetching suggestions for $_selectedCategory...");
    itemNames = await firestoreService.getItemNamesByCategory(_selectedCategory);
    itemNames = itemNames.toSet().toList(); // Remove duplicates
    itemDescriptions = await firestoreService.getItemDescriptionsByCategory(_selectedCategory);
    itemDescriptions = itemDescriptions.toSet().toList(); // Remove duplicates
    itemVendor = await firestoreService.getItemVendorByCategory(_selectedCategory);
    itemVendor = itemVendor.toSet().toList(); // Remove duplicates
    itemBuyingPrice = await firestoreService.getItemBuyingPriceByCategory(_selectedCategory);
    itemBuyingPrice = itemBuyingPrice.toSet().toList(); // Remove duplicates
    itemSellingPrice = await firestoreService.getItemSellingPriceByCategory(_selectedCategory);
    itemSellingPrice = itemSellingPrice.toSet().toList(); // Remove duplicates
    itemQuantity = await firestoreService.getItemQuantityByCategory(_selectedCategory);
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
        title: const Text('Add Item'),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
        leading: IconButton(
          onPressed: () {
            _clearItemSuggestions();
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
          icon: const Icon(Icons.arrow_back),
        ),
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
                    _buildDropdownField('Item Category', categories),
                    _buildDropdownFieldWithSuggestions('Item Name', itemNames, _nameController),
                    _buildDropdownFieldWithSuggestions('Item Description', itemDescriptions, _descriptionController, multiline: true),
                    _buildDropdownField('Item Color', colorNames, type: 'color'),
                    // Additional fields based on category
                    _buildDropdownField('Item Size', sizes, type: 'size'),
                    _buildDropdownFieldWithSuggestions('Item Vendor', itemVendor, _vendorController),
                    _buildDropdownFieldWithSuggestions('Item Buying Price', itemBuyingPrice, _buyingController, doubleOnly: true),
                    _buildDropdownFieldWithSuggestions('Item Selling Price', itemSellingPrice, _sellingController, doubleOnly: true),
                    _buildDropdownFieldWithSuggestions('Item Quantity', itemQuantity, _quantityController, integerOnly: true),
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
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontSize: 20.0),
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
                      child: const Text(
                        'Clear Text Fields',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String labelText, List<String> items, {String type='category'}) {
    // Check if the type is 'size' and the selected category is 'Clothes'
    if (type == 'size' && _selectedCategory != 'Clothes') {
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
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter $labelText';
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
                child: Text(suggestion.toString()),
              );
            }),
            const DropdownMenuItem<String>(
              value: '',
              child: Text('Enter your own'),
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
    if (_formKey.currentState?.validate() ?? false) {
      if (anyControllerEmpty([
        _nameController,
        _vendorController,
        _descriptionController,
        _buyingController,
        _sellingController,
        _quantityController,
      ])) {
        helper.showSnackBar('Please fill all fields!', "Error", ScaffoldMessenger.of(context));
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
                context, "Updating Quantity failed!", result['message']!);
          }
        } else {
          if (mounted) {
            helper.showSnackBar('Quantity successfully updated to ${existingProduct.quantity}!', "Success",
                ScaffoldMessenger.of(context), duration: 2);
          }
        }
      } else {
        // Add new product to Firebase
        Map<String, String> result = await firestoreService.addItem(newItem);
        if (result['status'] == 'Error') {
          if (mounted) {
            helper.showDialogBox(
                context, "Adding Item failed!", result['message']!);
          }
        } else {
          if (mounted) {
            helper.showSnackBar('Item added successfully!', "Success",
                ScaffoldMessenger.of(context), duration: 2);
          }
        }
      }
    } else {
      helper.showSnackBar('Please fill all fields!', "Error", ScaffoldMessenger.of(context));
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
}
