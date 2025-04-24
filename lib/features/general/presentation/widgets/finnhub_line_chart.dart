import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yukngantri/features/general/data/models/stock_price_model.dart';

class FinnhubLineChartWidget extends StatelessWidget {
  final bool isShowingMainData;
  final List<StockPrice> cryptoPrices;

  const FinnhubLineChartWidget({
    Key? key,
    required this.isShowingMainData,
    required this.cryptoPrices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2000000, // Interval 2 juta
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
                return Text(
                  DateFormat('HH:mm').format(date),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: cryptoPrices.isNotEmpty
                ? cryptoPrices
                .asMap()
                .entries
                .map((entry) => FlSpot(
              entry.value.timestamp,
              entry.value.price,
            ))
                .toList()
                : [],
            isCurved: true,
            color: Colors.red,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
        minY: cryptoPrices.isNotEmpty
            ? (cryptoPrices.map((e) => e.price).reduce((a, b) => a < b ? a : b) - 2000000)
            : 0,
        maxY: cryptoPrices.isNotEmpty
            ? (cryptoPrices.map((e) => e.price).reduce((a, b) => a > b ? a : b) + 2000000)
            : 0,
      ),
    );
  }
}