import 'package:flutter/material.dart';
import '../models/budget_entry.dart';
import '../widgets/spending_chart.dart'; // Adjust the import based on your file structure

class ChartScreen extends StatelessWidget {
  final List<BudgetEntry> entries;

  ChartScreen({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spending Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SpendingChart(entries: entries),
      ),
    );
  }
}
