import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_entry.dart';
import 'chart_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BudgetEntry> _entries = [];
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  String recurrence = 'monthly'; // Default recurrence
  String _sortBy = 'Date'; // Sorting options

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
      recurrence: recurrence,
      nextDueDate: DateTime.now().add(const Duration(days: 30)),
    );

    setState(() {
      _entries.add(newEntry);
    });

    _saveEntries();
    _categoryController.clear();
    _amountController.clear();
  }


  void _editEntry(int index) {
    final category = _categoryController.text;
    final amount = double.tryParse(_amountController.text);

    if (category.isEmpty || amount == null || amount <= 0) {
      return;
    }

    setState(() {
      // Replace the old entry with a new BudgetEntry
      _entries[index] = BudgetEntry(
        category: category,
        amount: amount,
        date: _entries[index].date,  // Keep the original date
        recurrence: _entries[index].recurrence,  // Keep original recurrence
        nextDueDate: _entries[index].nextDueDate,  // Keep original due date
      );
    });

    _saveEntries();
    _categoryController.clear();
    _amountController.clear();
  }

  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    _saveEntries();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryStrings = _entries.map((e) =>
    '${e.category},${e.amount},${e.date.toIso8601String()},${e.recurrence},${e.nextDueDate.toIso8601String()}'
    ).toList();
    await prefs.setStringList('entries', entryStrings);
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryStrings = prefs.getStringList('entries') ?? [];
    final loadedEntries = entryStrings.map((entryString) {
      final parts = entryString.split(',');

      return BudgetEntry(
        category: parts[0],
        amount: double.parse(parts[1]),
        date: DateTime.parse(parts[2]),
        recurrence: parts[3],
        nextDueDate: DateTime.parse(parts[4]),
      );
    }).toList();

    setState(() {
      _entries.addAll(loadedEntries);
    });
  }

  // Sorting function based on user selection
  void _sortEntries() {
    setState(() {
      if (_sortBy == 'Amount') {
        _entries.sort((a, b) => a.amount.compareTo(b.amount));
      } else if (_sortBy == 'Category') {
        _entries.sort((a, b) => a.category.compareTo(b.category));
      } else {
        _entries.sort((a, b) => a.date.compareTo(b.date));
      }
    });
  }

  // Export entries to CSV
  Future<void> _exportCSV() async {
    final headers = 'Category,Amount,Date,Recurrence,NextDueDate\n';
    final rows = _entries.map((e) =>
    '${e.category},${e.amount},${e.date.toIso8601String()},${e.recurrence},${e.nextDueDate.toIso8601String()}\n'
    ).join();
    final csvContent = headers + rows;

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/budget_entries.csv';
    final file = File(path);
    await file.writeAsString(csvContent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV exported to $path')),
    );
  }

  // Calculate total spending
  double _calculateTotalSpending() {
    return _entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<String>(
                  value: recurrence,
                  items: ['daily', 'weekly', 'monthly', 'yearly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      recurrence = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addEntry,
                  child: const Text('Add Entry'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartScreen(entries: _entries),
                      ),
                    );
                  },
                  child: const Text('View Chart'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _exportCSV,
                  child: const Text('Export to CSV'),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _sortBy,
                  items: ['Date', 'Amount', 'Category']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortBy = newValue!;
                      _sortEntries();
                    });
                  },
                ),
                Text('Total Spending: \$${_calculateTotalSpending().toStringAsFixed(2)}'),
              ],
            ),
          ),
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('No entries available.'))
                : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (ctx, index) {
                final entry = _entries[index];
                return ListTile(
                  title: Text(entry.category),
                  subtitle: Text('\$${entry.amount.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _categoryController.text = entry.category;
                          _amountController.text = entry.amount.toString();
                          _editEntry(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteEntry(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
