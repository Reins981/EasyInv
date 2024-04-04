// lib/models/item.dart
class Item {
  String? id;
  String name;
  String category;
  String? size;
  String color;
  String vendor;
  String description;
  double buyingPrice;
  double sellingPrice;
  int quantity;

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
    };
  }

}
