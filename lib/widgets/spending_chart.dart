import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/budget_entry.dart';

class SpendingChart extends StatelessWidget {
  final List<BudgetEntry> entries;

  const SpendingChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final categories = <String, double>{};
    for (var entry in entries) {
      categories[entry.category] = (categories[entry.category] ?? 0) + entry.amount;
    }

    if (categories.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final barChartData = categories.entries.map((e) {
      return BarChartGroupData(
        x: categories.keys.toList().indexOf(e.key),
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.blue,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 400,
      child: BarChart(
        BarChartData(
          barGroups: barChartData,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  final title = categories.keys.elementAt(index);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: const Color(0xff37434d),
              width: 1,
            ),
          ),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }
}
