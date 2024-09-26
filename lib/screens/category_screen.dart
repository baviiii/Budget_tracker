import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _categoryController = TextEditingController();
  final List<Category> _categories = [];

  void _addCategory() {
    final name = _categoryController.text;
    if (name.isEmpty) return;

    setState(() {
      _categories.add(Category(name));
    });

    _categoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
          ),
          ElevatedButton(
            onPressed: _addCategory,
            child: const Text('Add Category'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (ctx, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
