// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Item>> getAllItems() {
    // Method to get a stream of all items from Firestore
    return _firestore.collection('items').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Item.fromFirestore(doc.data(), doc))
        .toList());

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

  Future<Map<String, String>> deleteItem(String itemId) async {
    String errorMessage = "";
    bool isError = false;

    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
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
            profit: data['profit'],
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

  Future<Map<String, List<dynamic>>> getItemDataByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .where('category', isEqualTo: category)
          .get();

      List<String> names = [];
      List<String> descriptions = [];
      List<String> vendors = [];
      List<double> buyingPrices = [];
      List<double> sellingPrices = [];
      List<int> quantities = [];

      querySnapshot.docs.forEach((doc) {
        names.add(doc['name'] as String);
        descriptions.add(doc['description'] as String);
        vendors.add(doc['vendor'] as String);
        buyingPrices.add((doc['buyingPrice'] as num).toDouble());
        sellingPrices.add((doc['sellingPrice'] as num).toDouble());
        quantities.add((doc['quantity'] as num).toInt());
      });

      return {
        'names': names,
        'descriptions': descriptions,
        'vendors': vendors,
        'buyingPrices': buyingPrices,
        'sellingPrices': sellingPrices,
        'quantities': quantities,
      };
    } catch (e) {
      return {
        'names': [],
        'descriptions': [],
        'vendors': [],
        'buyingPrices': [],
        'sellingPrices': [],
        'quantities': [],
      };
    }
  }

  Future<List<Item>> getItemsSortedByQuantitySold({String order="descending"}) async {
    List<Item> itemList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('sales')
          .get();

      Map<String, int> quantitySoldMap = {};
      querySnapshot.docs.forEach((doc) {
        String itemId = doc['itemId'] as String;
        int quantitySold = doc['quantitySold'] as int;

        if (quantitySoldMap.containsKey(itemId)) {
          quantitySoldMap[itemId] = quantitySoldMap[itemId]! + quantitySold;
        } else {
          quantitySoldMap[itemId] = quantitySold;
        }
      });

      List<MapEntry<String, int>> sortedItems = [];
      if (order == "ascending") {
        // Sort the items by quantity sold in ascending order
        sortedItems = quantitySoldMap.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
      } else {
        // Sort the items by quantity sold in descending order
        sortedItems = quantitySoldMap.entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      }

      for (var entry in sortedItems) {
        String itemId = entry.key;

        // Fetch item from Firestore using itemId
        DocumentSnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('items')
            .doc(itemId)
            .get();

        if (querySnapshot.exists) {
          // Convert Firestore document to Item object
          Item item = Item.fromFirestore(querySnapshot.data() as Map<String, dynamic>, itemId);
          itemList.add(item);
        } else {
          print('Item with ID $itemId does not exist in the items collection.');
        }
      }

    } catch (e) {
      print('Failed to get items sorted by quantity sold: $e');
    }

    return itemList;
  }

  Future<List<Item>> getItemsSortedByProfit({String order="descending"}) async {
    List<Item> itemList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .orderBy('profit', descending: order == "descending")
          .get();

      List<Item> items = querySnapshot.docs
          .map((doc) => Item.fromFirestore(doc.data() as Map<String, dynamic>, doc))
          .toList();

      itemList = items;
    } catch (e) {
      print('Failed to get items sorted by profit: $e');
    }

    return itemList;
  }

  Future<List<Item>> getItemsSortedByName({String order="ascending"}) async {
    List<Item> itemList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('items')
          .orderBy('name', descending: order == "descending")
          .get();

      List<Item> items = querySnapshot.docs
          .map((doc) => Item.fromFirestore(doc.data() as Map<String, dynamic>, doc))
          .toList();

      itemList = items;
    } catch (e) {
      print('Failed to get items sorted by name: $e');
    }

    return itemList;
  }

}
