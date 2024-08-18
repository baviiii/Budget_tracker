import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/budget_entry.dart';

class SpendingChart extends StatelessWidget {
  final List<BudgetEntry> entries;

  SpendingChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    for (var entry in entries) {
      categories[entry.category] =
          (categories[entry.category] ?? 0) + entry.amount;
    }

    final barChartData = categories.entries.map((e) {
      return BarChartGroupData(
        x: categories.keys.toList().indexOf(e.key),
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.blue,
            width: 15,
          ),
        ],
      );
    }).toList();

    //   return BarChart(
    //     BarChartData(
    //       barGroups: barChartData,
    //       titlesData: FlTitlesData(
    //         bottomTitles: SideTitles(
    //           showTitles: true,
    //           reservedSize: 40,
    //           getTitlesWidget: (value, meta) {
    //             final index = value.toInt();
    //             final title = categories.keys.elementAt(index);
    //             return SideTitleWidget(
    //               axisSide: meta.axisSide,
    //               child: Text(title),
    //             );
    //           },
    //         ),
    //         leftTitles: SideTitles(
    //           showTitles: true,
    //           reservedSize: 40,
    //           getTitlesWidget: (value, meta) {
    //             return Text('${value.toString()}');
    //           },
    //         ),
    //         topTitles: SideTitles(showTitles: false),
    //         rightTitles: SideTitles(showTitles: false),
    //       ),
    //       borderData: FlBorderData(
    //         show: true,
    //         border: Border.all(
    //           color: const Color(0xff37434d),
    //           width: 1,
    //         ),
    //       ),
    //       gridData: FlGridData(show: false),
    //     ),
    //   );
    // }
  }
}
