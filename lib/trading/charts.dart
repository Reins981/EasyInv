import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_inv/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/item.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';

class TradingChart extends StatefulWidget {
  final Item item;
  final String itemId;
  final FirestoreService firestoreService;

  const TradingChart({
    super.key,
    required this.item,
    required this.itemId,
    required this.firestoreService
  });

  @override
  _TradingChartState createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart> {
  late Future<List<SalesData>> futureData;
  late Map<String, int> upsAndDowns;
  Color graphColor = Colors.green;
  Helper _helper = Helper();

  @override
  void initState() {
    super.initState();
    futureData = _getOneMonthData(widget.itemId);
    futureData.then((data) {
      upsAndDowns = _calculateNumberOfUpsAndDowns(data);
      int upDays = upsAndDowns['upDays']!;
      int downDays = upsAndDowns['downDays']!;
      int neutralDays = upsAndDowns['neutralDays']!;
      graphColor = upDays > downDays ? Colors.green : upDays == downDays ? Colors.yellow : Colors.red;
      if (neutralDays > upDays && neutralDays > downDays) {
        graphColor = Colors.yellow;
      }
      widget.item.trend = graphColor == Colors.green ? 'up' : graphColor == Colors.red ? 'down' : 'flat';
      widget.firestoreService.updateItem(widget.item, widget.item.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SalesData>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pink),
          ));
        } else if (snapshot.hasError) {
          return _helper.showStatus('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _helper.showStatus('No data available');
        } else {
          List<SalesData> data = snapshot.data!;
          return SizedBox(
            height: 100,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(isVisible: false),
              primaryYAxis: NumericAxis(isVisible: false),
              series: <ChartSeries>[
                LineSeries<SalesData, int>(
                  dataSource: data,
                  xValueMapper: (SalesData sales, _) => sales.day,
                  yValueMapper: (SalesData sales, _) => sales.sales,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  enableTooltip: true,
                  markerSettings: MarkerSettings(
                    isVisible: false,
                    color: graphColor,
                  ),
                  color: graphColor,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Map<String, int> _calculateNumberOfUpsAndDowns(List<SalesData> data) {
    // This function should return the number of days the item sales went up and the number of days it went down
    // For example, you can return the number of days the item sales went up in the last 30 days
    // and the number of days it went down in the last 30 days
    // You can use the data from _getOneMonthData() to calculate this
    // Example:
    int upDays = 0;
    int downDays = 0;
    int neutralDays = 0;
    for (int i = 1; i < data.length; i++) {
      if (data[i].sales > data[i - 1].sales) {
        upDays++;
      } else if (data[i].sales < data[i - 1].sales) {
        downDays++;
      } else if (data[i].sales == data[i - 1].sales) {
        neutralDays++;
      }
    }
    return {
      'upDays': upDays,
      'downDays': downDays,
      'neutralDays': neutralDays
    };
  }

  // Function to get one month data
  Future<List<SalesData>> _getOneMonthData(String itemId) async {
    // This function should return data for one month
    // For example, you can return the data for the last 30 days
    List<SalesData> data = [];
    // Add your data points here
    // Function to get one month data from firestore
    DateTime currentTime = DateTime.now();
    DateTime oneMonthAgo = currentTime.subtract(const Duration(days: 30));

    // Query Firestore for sales data of the specific item in the last 30 days
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('itemId', isEqualTo: itemId)
        .where('date', isGreaterThanOrEqualTo: oneMonthAgo)
        .where('date', isLessThanOrEqualTo: currentTime)
        .get();

    Map<int, dynamic> dailySales = {};

    // Convert querySnapshot to List<SalesData>
    querySnapshot.docs.forEach((doc) {
      DateTime salesDate = (doc['date'] as Timestamp).toDate();
      int day = salesDate.day;
      dynamic sales = doc['sales'];

      if (dailySales.containsKey(day)) {
        dailySales[day] = dailySales[day]! + sales;
      } else {
        dailySales[day] = sales;
      }
    });

    dailySales.forEach((day, sales) {
      data.add(SalesData(day, sales));
    });

    return data;
  }
}

class SalesData {
  SalesData(this.day, this.sales);

  final int day; // Day of the month
  final dynamic sales; // Sales is the profit * number of items sold

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'sales': sales,
    };
  }
}
