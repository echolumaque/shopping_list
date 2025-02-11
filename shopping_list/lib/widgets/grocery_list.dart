import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import '../widgets/new_item.dart';
import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _addItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );

    _loadItems();
  }

  void _loadItems() async {
    final response = await http.get(
      Uri.https(
        'shopping-list-flutter-c4675-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json',
      ),
    );
    final responseBody = response.body;
    if (responseBody.isEmpty) {
      return;
    }

    final List<GroceryItem> loadedItems = [];
    final Map<String, dynamic> listData = json.decode(responseBody);
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (category) => category.value.title == item.value['category'],
          )
          .value;

      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text('You got no items yet.'));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          final item = _groceryItems[index];

          return Dismissible(
            key: ValueKey(item.id),
            onDismissed: (direction) {
              _groceryItems.remove(item);
            },
            child: ListTile(
              title: Text(item.name),
              leading: SizedBox(
                height: 24,
                width: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: item.category.color),
                ),
              ),
              trailing: Text('${item.quantity}'),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
