import 'package:flutter/material.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({Key? key}) : super(key: key);

  @override
  _AssetManagementScreenState createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Management'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildSortingColumns(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildItemList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name, vendor, or category',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSortingColumns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSortColumn('Trending'),
        _buildSortColumn('Top Profits'),
        _buildSortColumn('A-Z'),
      ],
    );
  }

  Widget _buildSortColumn(String title) {
    return GestureDetector(
      onTap: () {
        // Implement sorting logic based on the column tapped
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    // Implement the list of items based on the search query and sorting criteria
    // This can be a ListView.builder or a custom widget depending on your data source
    return ListView.builder(
      itemCount: 10, // Replace with the actual item count
      itemBuilder: (context, index) {
        // Build each item widget here
        return ListTile(
          leading: Icon(Icons.shopping_bag),
          title: Text('Item $index'),
          subtitle: Text('Description of Item $index'),
          trailing: Text('\$10'), // Example price
        );
      },
    );
  }
}

