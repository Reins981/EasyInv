import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../widgets/dashboard_search.dart';
import 'add_item_screen.dart';
import '../screens/asset_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;
  late Animation<double> _animation;
  Helper helper = Helper();
  List<Item> lowStockItems = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the animation controller
    _animationController.dispose(); // Dispose the animation controller
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
          'Inventory Dashboard',
          style: GoogleFonts.lato(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.rosa,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Item>>(
            stream: firestoreService.getAllItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
                ));
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay artículos en inventario.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 20),
                      _buildAddItemButton(context),
                    ],
                  ),
                );
              }

              // Calculate inventory statistics
              final totalItems = snapshot.data!.length;
              final totalCategories = snapshot.data!.map((item) => item.category).toSet().length;
              lowStockItems = snapshot.data!.where((item) => item.quantity < 5).toList();

              double totalProfit = snapshot.data!.fold(0, (total, item) => total + item.profit);
              double chartHeight = calculateChartHeight(snapshot.data!);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalProfitWidget(context, totalProfit),
                    const SizedBox(height: 20),
                    TotalsAndAddItemCard(
                      totalItems: totalItems,
                      totalCategories: totalCategories,
                      onAddItem: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddItemScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    LowStockItemWidget(
                        items: lowStockItems
                    ),
                    const SizedBox(height: 20),
                    _buildInventoryChart(snapshot.data!, chartHeight),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 80, // Position above the bottom button
            right: 16,
            child: FloatingActionButton(
              heroTag: 'vertical_align_top',
              mini: true,
              backgroundColor: AppColors.rosa, // Set background color to transparent
              foregroundColor: Colors.white, // Set foreground color to rosa
              child: const Icon(Icons.vertical_align_top), // Icon indicating upwards scrolling
              onPressed: () {
                _scrollToTop();
              },
            ),
          ),
          Positioned(
            bottom: 16, // Adjust the position as needed
            right: 16, // Adjust the position as needed
            child: FloatingActionButton(
              heroTag: 'vertical_align_bottom',
              mini: true, // Makes the button smaller
              backgroundColor: AppColors.rosa, // Set background color to transparent
              foregroundColor: Colors.white,
              child: const Icon(Icons.vertical_align_bottom), // Icon for the button
              onPressed: () {
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0, // Scroll to the top
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget _buildTotalProfitWidget(BuildContext context, double totalProfit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purpleAccent, Colors.pink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _animation, // Assuming _animation is defined in your State class
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$$totalProfit',
                    style: GoogleFonts.lato(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              _buildInventoryButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssetManagementScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.purpleAccent,
              backgroundColor: Colors.white,
              shape: CircleBorder(),
              padding: const EdgeInsets.all(16.0),
              elevation: 4,
            ),
            child: const Icon(
              Icons.inventory,
              color: Colors.purpleAccent,
              size: 30.0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int value) {
    Icon resultIcon = title == 'Total de artículos'
        ? const Icon(Icons.shopping_cart, color: Colors.white, size: 60.0)
        : const Icon(Icons.category, color: Colors.white, size: 60.0);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.rosa,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  resultIcon,
                  const SizedBox(height: 8.0),
                  Text(
                    value.toString(),
                    style: GoogleFonts.lato(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double calculateChartHeight(List<Item> items) {
    // Adjust this multiplier based on your preference
    double itemHeight = 60.0;
    int itemCount = items.length;
    // Calculate the total height based on the number of items
    double totalHeight = itemCount * itemHeight;
    // Add extra padding or spacing as needed
    double paddingHeight = 100.0;
    // Return the total height plus padding
    return totalHeight + paddingHeight;
  }

  Widget _buildInventoryChart(List<Item> items, double chartHeight) {
    items.sort((a, b) {
      // First, compare by vendor
      int vendorComparison = a.vendor.compareTo(b.vendor);
      if (vendorComparison != 0) {
        return vendorComparison;
      }

      // If vendors are equal, compare by category
      return a.category.compareTo(b.category);
    });

    final data = [
      charts.Series<Item, String>(
        id: 'Inventory',
        domainFn: (Item item, _) => _buildDomainText(item),
        measureFn: (Item item, _) => item.quantity,
        data: items,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppColors.pink),
      ),
    ];

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Set vertical scrolling
          child: SizedBox(
            height: chartHeight,
            child: charts.BarChart(
              data,
              animate: true,
              animationDuration: const Duration(milliseconds: 1500),
              vertical: false, // Set vertical to false for horizontal orientation
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: const charts.OrdinalAxisSpec(
                renderSpec: charts.NoneRenderSpec(),
              ),
              defaultRenderer: charts.BarRendererConfig<String>(
                cornerStrategy: const charts.ConstCornerStrategy(12),
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                // Adjust the radius for rounded corners
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildDomainText(Item item) {
    return '${_buildVendorText(item.vendor)} '
        '- ${item.name.length > 20 ? "${item.name.substring(0, 20)}...": item.name} '
        '- ${item.description.length > 20 ? "${item.description.substring(0, 20)}...": item.description} '
        '- ${item.color} '
        '- ${item.size ?? "N/D"} '
        '- (${item.quantity})';
  }

  String _buildVendorText(String vendor) {
    return vendor.length > 20 ? '${vendor.substring(0, 20)}...' : vendor;
  }

  Widget _buildAddItemButton(BuildContext context) {
    return Center( // Center widget added here
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.rosa,
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          minimumSize: const Size(double.infinity, 60),
        ),
        child: Text(
          'Agregar artículo',
          style: GoogleFonts.lato(
            fontSize: 20,
            color: AppColors.rosa,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class TotalsAndAddItemCard extends StatelessWidget {
  final int totalItems;
  final int totalCategories;
  final VoidCallback onAddItem;

  const TotalsAndAddItemCard({
    Key? key,
    required this.totalItems,
    required this.totalCategories,
    required this.onAddItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCard('Total de artículos', totalItems),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCard('Total de categorías', totalCategories),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
            Center( // Center widget added here
              child: ElevatedButton(
                onPressed: onAddItem,
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.rosa,
                  backgroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: Text(
                  'Agregar artículo',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    color: AppColors.rosa,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    Icon resultIcon = title == 'Total de artículos'
        ? const Icon(Icons.shopping_cart, color: Colors.white, size: 60.0)
        : const Icon(Icons.category, color: Colors.white, size: 60.0);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: AppColors.rosa,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  resultIcon,
                  const SizedBox(height: 8.0),
                  Text(
                    value.toString(),
                    style: GoogleFonts.lato(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

