// lib/services/firestore_service.dart
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Item>> getAllItems() async {
    // Retrieve all items from Firestore
    QuerySnapshot querySnapshot = await _firestore.collection('items').get();
    return querySnapshot.docs
        .map((doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        return Item(
          id: doc.id,
          name: data['name'],
          category: data['category'],
          color: data['color'],
          size: data.containsKey('size') && data['size'] != null ? data['size'] : null,
          vendor: data['vendor'],
          description: data['description'],
          buyingPrice: data['buyingPrice'],
          sellingPrice: data['sellingPrice'],
          quantity: data['quantity'],
        );
      } else {
        // Return an empty list to ignore this document
        return [];
      }
    })
        .whereType<Item>() // Filter out null values
        .toList();
  }

  Future<Map<String, String>> updateItem(Item item, String itemId) async {
    String errorMessage = "";
    bool isError = false;

    try {
      // Update item in Firestore
      await _firestore.collection('items').doc(itemId).update(item.toJson());
    } catch (e) {
      errorMessage = '$e';
      isError = true;
    }

    return isError ? {
      'status': 'Error',
      'message': errorMessage
    } : {
      'status': 'Success',
      'message': ""
    };
  }

  Future<Map<String, String>> addItem(Item item) async {
    String errorMessage = "";
    bool isError = false;

    try {
      // Add item to Firestore
      await _firestore.collection('items').add(item.toJson());
    } catch (e) {
      errorMessage = '$e';
      isError = true;
    }

    return isError ? {
      'status': 'Error',
      'message': errorMessage
    } : {
      'status': 'Success',
      'message': ""
    };
  }

  Future<Map<String, dynamic>> getItemByFields(Item newItem) async {
    try {
      late QuerySnapshot querySnapshot;
      if (newItem.size != null) {
        querySnapshot = await _firestore.collection('items')
            .where('category', isEqualTo: newItem.category)
            .where('name', isEqualTo: newItem.name)
            .where('description', isEqualTo: newItem.description)
            .where('color', isEqualTo: newItem.color)
            .where('size', isEqualTo: newItem.size)
            .where('vendor', isEqualTo: newItem.vendor)
            .where('buyingPrice', isEqualTo: newItem.buyingPrice)
            .where('sellingPrice', isEqualTo: newItem.sellingPrice)
            .get();
      } else {
        querySnapshot = await _firestore.collection('items')
            .where('category', isEqualTo: newItem.category)
            .where('name', isEqualTo: newItem.name)
            .where('description', isEqualTo: newItem.description)
            .where('color', isEqualTo: newItem.color)
            .where('vendor', isEqualTo: newItem.vendor)
            .where('buyingPrice', isEqualTo: newItem.buyingPrice)
            .where('sellingPrice', isEqualTo: newItem.sellingPrice)
            .get();
      }

      // Check if any matching product is found
      if (querySnapshot.docs.isNotEmpty) {
        // Construct the Item object from the document data
        Map<String, dynamic> data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'item': Item(
            name: data['name'],
            category: data['category'],
            color: data['color'],
            size: data.containsKey('size') ? data['size'] : null,
            vendor: data['vendor'],
            description: data['description'],
            buyingPrice: data['buyingPrice'],
            sellingPrice: data['sellingPrice'],
            quantity: data['quantity'], // Retrieve quantity from the document
          ),
          'itemId': querySnapshot.docs.first.id, // Retrieve the document ID
          'status': 'Success'
        };
      } else {
        return {
          'item': null,
          'itemId': null,
          'status': 'Success'
        };
      }
    } catch (e) {
      return {
        'item': null,
        'itemId': null,
        'status': '$e'
      };
    }
  }

  Future<List<String>> getItemNamesByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getItemDescriptionsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) => doc['description'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getItemVendorByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) => doc['vendor'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<double>> getItemBuyingPriceByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => (doc['buyingPrice'] as num).toDouble())
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<double>> getItemSellingPriceByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => (doc['sellingPrice'] as num).toDouble()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<int>> getItemQuantityByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => (doc['quantity'] as num).toInt()).toList();
    } catch (e) {
      return [];
    }
  }

}
