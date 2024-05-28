// lib/models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    };
  }

  static Item fromFirestore(Map<String, dynamic> data, QueryDocumentSnapshot doc) {
    return Item(
      id: doc.id,
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
    );
  }

  Future<void> recordSale(int quantitySold) async {
    final sales = quantitySold * (sellingPrice - buyingPrice);
    final saleDate = Timestamp.now();

    await FirebaseFirestore.instance.collection('items').doc(id).update({
      'quantity': quantity - quantitySold,
    });

    await FirebaseFirestore.instance.collection('sales').add({
      'itemId': id,
      'quantitySold': quantitySold,
      'sales': sales,
      'date': saleDate,
    });
    // Update the local quantity
    quantity = quantity - quantitySold;
  }

}
