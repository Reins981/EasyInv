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

  Future<List<Item>> getItemsSortedByQuantitySold({String order = "descending"}) async {
    List<Item> itemList = [];
    try {
      // Fetch all sales data
      QuerySnapshot salesSnapshot = await _firestore.collection('sales').get();

      // Calculate the total quantity sold for each item
      Map<String, int> quantitySoldMap = {};
      for (var doc in salesSnapshot.docs) {
        String itemId = doc['itemId'] as String;
        int quantitySold = doc['quantitySold'] as int;

        if (quantitySoldMap.containsKey(itemId)) {
          quantitySoldMap[itemId] = quantitySoldMap[itemId]! + quantitySold;
        } else {
          quantitySoldMap[itemId] = quantitySold;
        }
      }

      // Sort items based on quantity sold
      List<MapEntry<String, int>> sortedEntries = quantitySoldMap.entries.toList()
        ..sort((a, b) => order == "ascending" ? a.value.compareTo(b.value) : b.value.compareTo(a.value));

      // Fetch all items in sorted order using batch retrieval
      List<String> sortedItemIds = sortedEntries.map((e) => e.key).toList();

      Map<String, Item> itemsMap = {};
      for (int i = 0; i < sortedItemIds.length; i += 10) {
        List<String> batchIds = sortedItemIds.sublist(i, i + 10 > sortedItemIds.length ? sortedItemIds.length : i + 10);
        QuerySnapshot itemSnapshot = await _firestore.collection('items').where(FieldPath.documentId, whereIn: batchIds).get();
        for (var doc in itemSnapshot.docs) {
          Item item = Item.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          itemsMap[doc.id] = item;
        }
      }

      // Reorder the items based on sortedItemIds
      for(var itemId in sortedItemIds) {
        if (itemsMap.containsKey(itemId)) {
          itemList.add(itemsMap[itemId]!);
        }
      }

      // Fetch remaining items that do not have sales data
      QuerySnapshot remainingItemsSnapshot = await _firestore.collection('items').get();
      for (var doc in remainingItemsSnapshot.docs) {
        if (!quantitySoldMap.containsKey(doc.id)) {
          Item item = Item.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          itemList.add(item);
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
