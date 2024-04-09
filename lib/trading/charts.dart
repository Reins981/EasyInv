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
  List<SalesData> _getOneMonthData() {
    // This function should return data for one month
    // For example, you can return the data for the last 30 days
    List<SalesData> data = [];
    // Add your data points here
    // Example:
    data.add(SalesData(1, 5)); // Day 1, value 5
    data.add(SalesData(2, 10)); // Day 2, value 10
    data.add(SalesData(3, 15)); // Day 3, value 15
    data.add(SalesData(4, 12)); // Day 4, value 12
    data.add(SalesData(5, 18)); // Day 5, value 18
    data.add(SalesData(6, 20)); // Day 6, value 20
    data.add(SalesData(7, 17)); // Day 7, value 17
    data.add(SalesData(8, 16)); // Day 8, value 16
    data.add(SalesData(9, 200)); // Day 9, value 14
    data.add(SalesData(10, 12)); // Day 10, value 12
    data.add(SalesData(11, 12)); // Day 10, value 12
    data.add(SalesData(12, 12)); // Day 10, value 12
    data.add(SalesData(13, 12)); // Day 10, value 12
    data.add(SalesData(14, 12)); // Day 10, value 12
    data.add(SalesData(15, 12)); // Day 10, value 12
    data.add(SalesData(16, 12)); // Day 10, value 12
    data.add(SalesData(17, 12)); // Day 10, value 12
    data.add(SalesData(18, 12)); // Day 10, value 12
    data.add(SalesData(19, 12)); // Day 10, value 12
    data.add(SalesData(20, 12)); // Day 10, value 12
    data.add(SalesData(21, 12)); // Day 10, value 12
    data.add(SalesData(22, 12)); // Day 10, value 12
    data.add(SalesData(23, 12)); // Day 10, value 12
    data.add(SalesData(24, 12)); // Day 10, value 12
    data.add(SalesData(25, 12)); // Day 10, value 12
    data.add(SalesData(26, 12)); // Day 10, value 12
    data.add(SalesData(27, 12)); // Day 10, value 12
    data.add(SalesData(28, 12)); // Day 10, value 12
    data.add(SalesData(29, 12)); // Day 10, value 12
    data.add(SalesData(30, 12)); // Day 10, value 12


    // ...
    return data;
  }
}

class SalesData {
  SalesData(this.day, this.sales);

  final int day; // Day of the month
  final double sales; // Sales is the profit * number of items sold
}
