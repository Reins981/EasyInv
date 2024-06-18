import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../trading/charts.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../providers/search_provider.dart';
import 'item_details.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({Key? key}) : super(key: key);

  @override
  _AssetManagementScreenState createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  late Animation<double> _animation;
  String trendOrder = 'ascending';
  String profitOrder = 'descending';
  String nameOrder = 'ascending';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Activos',
          style: GoogleFonts.lato(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
        actions: [
          IconButton(
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          final items = searchProvider.items;
          if (items == null) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
            ));
          }
          return Column(
            children: [
              const SizedBox(height: 16.0),
              _buildSearchBar(context),
              const SizedBox(height: 20.0),
              _buildSortingColumns(),
              Expanded(
                child: _buildItemList(items),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.rosa,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<SearchProvider>(context, listen: false).setSearchText(value);
              },
              style: const TextStyle(color: Colors.black),
              cursorColor: AppColors.pink,
              decoration: InputDecoration(
                labelText: 'Buscar por Proveedor, Nombre o Categoría',
                labelStyle: const TextStyle(color: AppColors.pink),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.pink),
                  onPressed: () {
                    Provider.of<SearchProvider>(context, listen: false).setSearchText('');
                    _searchController.clear();
                  },
                ),
                suffixIconColor: AppColors.pink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortingColumns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded( child: _buildSortColumn('Tendencias')),
        Expanded( child: _buildSortColumn('Ganancias')),
        Expanded( child: _buildSortColumn('A-Z')),
      ],
    );
  }

  Widget _buildSortColumn(String title) {
    return GestureDetector(
      onTap: () {
        title == 'Tendencias'
            ? Provider.of<SearchProvider>(context, listen: false).getItemsSortedByQuantitySold(order: trendOrder)
            : title == 'Ganancias'
            ? Provider.of<SearchProvider>(context, listen: false).getItemsSortedByProfit(order: profitOrder)
            : Provider.of<SearchProvider>(context, listen: false).getItemsSortedByName(order: nameOrder);

        if (title == 'Tendencias') {
          trendOrder = trendOrder == 'descending' ? 'ascending' : 'descending';
        } else if (title == 'Ganancias') {
          profitOrder = profitOrder == 'descending' ? 'ascending' : 'descending';
        } else {
          nameOrder = nameOrder == 'ascending' ? 'descending' : 'ascending';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.pink,
          border: Border.all(color: AppColors.pink),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(List<Item> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(
              items[index].name,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubtitle(items[index].vendor),
                      _buildSubtitle(items[index].description),
                      _buildSubtitle(items[index].color),
                      _buildSubtitle(items[index].size ?? 'N/D'),
                      _buildSubtitle("(${items[index].quantity.toString()})", bold: true),
                    ],
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TradingChart(
                          key: ValueKey(items[index].id),
                          item: items[index],
                          itemId: items[index].id!,
                          firestoreService: FirestoreService()
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceContainer(items[index].buyingPrice, Colors.red),
                      _buildPriceContainer(items[index].sellingPrice, Colors.green),
                      _buildProfitContainer(items[index].profit),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailScreen(item: items[index], helper: Helper()),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        value.length > 6 ? '${value.substring(0, 6)}..' : value,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.0,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildPriceContainer(dynamic price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          '\$$price',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProfitContainer(dynamic profit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purpleAccent, AppColors.pink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ScaleTransition(
              scale: _animation,
              child: const Icon(
                Icons.attach_money,
                color: Colors.white,
                size: 14.0,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                '$profit',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
