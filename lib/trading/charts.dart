import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TradingChart extends StatefulWidget {
  const TradingChart({Key? key}) : super(key: key);

  @override
  _TradingChartState createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart> {
  late List<SalesData> data;
  late Map<String, int> upsAndDowns;
  Color graphColor = Colors.green;

  @override
  void initState() {
    super.initState();
    // Call the function to calculate the number of days the stock price went up and down
    data = _getOneMonthData();
    upsAndDowns = _calculateNumberOfUpsAndDowns(data);
    int upDays = upsAndDowns['upDays']!;
    int downDays = upsAndDowns['downDays']!;
    int neutralDays = upsAndDowns['neutralDays']!;
    graphColor = upDays > downDays ? Colors.green : Colors.red;
    if (neutralDays > upDays && neutralDays > downDays) {
      graphColor = Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Adjust height as needed
      child: SfCartesianChart(
        // Configure the chart here
        plotAreaBorderWidth: 0,
        primaryXAxis: NumericAxis(
          isVisible: false, // Hide X axis
        ),
        primaryYAxis: NumericAxis(
          isVisible: false, // Hide Y axis
        ),
        series: <ChartSeries>[
          LineSeries<SalesData, int>(
            dataSource: data, // Show only one month data
            xValueMapper: (SalesData sales, _) => sales.day,
            yValueMapper: (SalesData sales, _) => sales.sales,
            dataLabelSettings: const DataLabelSettings(
              isVisible: false,
              textStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            enableTooltip: true,
            markerSettings: MarkerSettings(
              isVisible: false,
              color: graphColor,
            ),
            color: graphColor, // Change line color
          ),
        ],
      ),
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
  Future<List<SalesData>> _getOneMonthData() async {
    // This function should return data for one month
    // For example, you can return the data for the last 30 days
    List<SalesData> data = [];
    // Add your data points here
    // Function to get one month data from firestore
    DateTime currentTime = DateTime.now();
    DateTime oneMonthAgo = currentTime.subtract(const Duration(days: 30));

    // Get data from Firestore for the last 30 days
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('date', isGreaterThanOrEqualTo: oneMonthAgo)
        .where('date', isLessThanOrEqualTo: currentTime)
        .get();

    // Convert querySnapshot to List<SalesData>
    querySnapshot.docs.forEach((doc) {
      data.add(SalesData(doc['day'], doc['sales']));
    });

    // ...
    return data;
  }
}

class SalesData {
  SalesData(this.day, this.sales);

  final int day; // Day of the month
  final double sales; // Sales is the profit * number of items sold
}
