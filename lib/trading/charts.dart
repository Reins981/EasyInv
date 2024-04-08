import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TradingChart extends StatelessWidget {
  const TradingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100, // Adjust height as needed
        child: SfCartesianChart(
          // Configure the chart here
          series: <ChartSeries>[
            LineSeries<SalesData, double>(
              dataSource: <SalesData>[
                SalesData(0, 5),
                SalesData(1, 10),
                SalesData(2, 15),
                SalesData(2, 15.4),
                SalesData(2, 15.1),
                SalesData(2, 15.9),
                SalesData(2, 16),
                SalesData(2, 15.6),
                SalesData(2, 15.8),
                // Add more data points as needed
              ],
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
            ),
          ],
          primaryXAxis: NumericAxis(),
          primaryYAxis: NumericAxis(),
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final double year;
  final double sales;
}
