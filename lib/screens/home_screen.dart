import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_entry.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BudgetEntry> _entries = [];
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _addEntry() {
    final category = _categoryController.text;
    final amount = double.tryParse(_amountController.text);

    if (category.isEmpty || amount == null || amount <= 0) {
      return;
    }

    final newEntry = BudgetEntry(
      category: category,
      amount: amount,
      date: DateTime.now(),
    );

    setState(() {
      _entries.add(newEntry);
    });

    _categoryController.clear();
    _amountController.clear();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryStrings = _entries.map((e) =>
    '${e.category},${e.amount},${e.date.toIso8601String()}'
    ).toList();
    await prefs.setStringList('entries', entryStrings);
    print('Entries saved: $entryStrings');
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryStrings = prefs.getStringList('entries') ?? [];
    print('Entries loaded: $entryStrings');
    final loadedEntries = entryStrings.map((entryString) {
      final parts = entryString.split(',');
      return BudgetEntry(
        category: parts[0],
        amount: double.parse(parts[1]),
        date: DateTime.parse(parts[2]),
      );
    }).toList();
    setState(() {
      _entries.addAll(loadedEntries);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addEntry,
                  child: Text('Add Entry'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveEntries,
                  child: Text('Save Entries'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loadEntries,
                  child: Text('Load Entries'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (ctx, index) {
                final entry = _entries[index];
                return ListTile(
                  title: Text(entry.category),
                  subtitle: Text('\$${entry.amount.toStringAsFixed(2)}'),
                  trailing: Text('${entry.date.toLocal()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
