import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/extensions/http_response_extension.dart';
import '../enums/constants.dart';
import '../widgets/new_item.dart';
import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  String? _error;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _addItem() async {
    final groceryItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );

    if (groceryItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(groceryItem);
    });
  }

  void _deleteItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final response = await http.delete(
      Uri.https(
        Constants.firebaseBaseUrl.constValue,
        'shopping-list/${item.id}.json',
      ),
    );

    if (!response.isOk) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to delete a grocery. Re-adding it again.'),
          ),
        );
      }

      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  void _loadItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        Uri.https(
          Constants.firebaseBaseUrl.constValue,
          Constants.firebaseJsonToUse.constValue,
        ),
      );
      final responseBody = response.body;
      if (responseBody.isEmpty || !response.isOk || response.body == 'null') {
        setState(() {
          _error = response.body == 'null'
              ? 'Groceries are empty. Add now!'
              : 'Failed to fetch data. Please try again later.';
          _isLoading = false;
        });
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
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    } else {
      if (_groceryItems.isEmpty) {
        content = Center(child: Text('You got no items yet.'));
      } else {
        content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) {
            final item = _groceryItems[index];

            return Dismissible(
              key: ValueKey(item.id),
              onDismissed: (direction) {
                _deleteItem(item);
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
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
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
