// lib/models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String? id;
  String name;
  String category;
  String? size;
  String color;
  String vendor;
  String description;
  dynamic buyingPrice;
  dynamic sellingPrice;
  int quantity;
  dynamic profit = 0;
  String? trend;
  int totalQuantitySold = 0;

  Item({
    this.id,
    required this.name,
    required this.category,
    this.size,
    required this.color,
    required this.vendor,
    required this.description,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.profit,
    this.trend,
    required this.totalQuantitySold,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      if (size != null) 'size': size,
      'color': color,
      'vendor': vendor,
      'description': description,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'profit': profit,
      if (trend != null) 'trend': trend,
      'totalQuantitySold': totalQuantitySold,
    };
  }

  static Item fromFirestore(Map<String, dynamic> data, [dynamic secondParam]) {
    if (secondParam is String) {
      // Create item when secondParam is a String (assuming it's the ID)
      return Item(
        id: secondParam,
        name: data['name'],
        category: data['category'],
        size: data['size'],
        color: data['color'],
        vendor: data['vendor'],
        description: data['description'],
        buyingPrice: data['buyingPrice'],
        sellingPrice: data['sellingPrice'],
        quantity: data['quantity'],
        profit: data['profit'],
        trend: data['trend'],
        totalQuantitySold: data['totalQuantitySold'] ?? 0,
      );
    } else if (secondParam is QueryDocumentSnapshot) {
      // Create item when secondParam is a QueryDocumentSnapshot
      return Item(
        id: secondParam.id,
        name: data['name'],
        category: data['category'],
        size: data['size'],
        color: data['color'],
        vendor: data['vendor'],
        description: data['description'],
        buyingPrice: data['buyingPrice'],
        sellingPrice: data['sellingPrice'],
        quantity: data['quantity'],
        profit: data['profit'],
        trend: data['trend'],
        totalQuantitySold: data['totalQuantitySold'] ?? 0,
      );
    } else {
      throw ArgumentError('Second parameter must be either a String or a QueryDocumentSnapshot');
    }
  }

  Future<Map<String, String>> recordSale(int quantitySold) async {
    final sales = sellingPrice > buyingPrice ? quantitySold * (sellingPrice - buyingPrice) : 0;
    final saleDate = Timestamp.now();

    try {
      totalQuantitySold = totalQuantitySold + quantitySold;
      quantity = quantity - quantitySold;
      profit = profit + sales;

      await FirebaseFirestore.instance.collection('items').doc(id).update({
        'quantity': quantity,
        'profit': profit,
        'totalQuantitySold': totalQuantitySold,
      });

      await FirebaseFirestore.instance.collection('sales').add({
        'itemId': id,
        'quantitySold': quantitySold,
        'sales': sales,
        'date': saleDate,
      });

      return {'status': 'Success', 'message': 'Sale recorded successfully'};
    } catch (e) {
      return {'status': 'Error', 'message': '$e'};
    }
  }

}
