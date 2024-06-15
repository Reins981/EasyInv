import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';

class SearchProvider with ChangeNotifier {
  final FirestoreService firestoreService;
  List<Item>? _items;
  List<Item>? _filteredItems;
  String _searchText = '';

  SearchProvider(this.firestoreService) {
    _fetchItems();
  }

  List<Item>? get items => _filteredItems ?? _items;

  String get searchText => _searchText;

  void setSearchText(String searchText) {
    _searchText = searchText;
    _filterItems();
    notifyListeners();
  }

  Future<void> _fetchItems() async {
    try {
      // Listen to the stream of items from Firestore
      firestoreService.getAllItems().listen((List<Item>? fetchedItems) {
        if (fetchedItems != null) {
          fetchedItems.sort((a, b) {
            // First, compare by vendor
            int vendorComparison = a.vendor.compareTo(b.vendor);
            if (vendorComparison != 0) {
              return vendorComparison;
            }
            // If vendors are equal, compare by category
            return a.category.compareTo(b.category);
          });
        }
        _items = fetchedItems;
        _filterItems();
        notifyListeners();
      }, onError: (dynamic error) {
        // Handle stream errors
        print('Stream error: $error');
        // Optionally set _items or _filteredItems to null or handle the error state
        _items = null;
        _filteredItems = null;
        notifyListeners(); // Notify listeners about the error state
      });
    } catch (e) {
      // Handle the error here
      print('Failed to fetch items: $e');
      // Optionally, set _items or _filteredItems to null or handle the error state
      _items = null;
      _filteredItems = null;
      notifyListeners(); // Notify listeners about the error state
    }
  }

  void _filterItems() {
    if (_searchText.isEmpty) {
      _filteredItems = null;
    } else {
      final lowerSearchText = _searchText.toLowerCase();
      _filteredItems = _items?.where((item) {
        return item.name.toLowerCase().contains(lowerSearchText) ||
            item.vendor.toLowerCase().contains(lowerSearchText) ||
            item.category.toLowerCase().contains(lowerSearchText);
      }).toList();
    }
  }
}
