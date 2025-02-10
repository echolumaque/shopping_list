import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import '../widgets/new_item.dart';
import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  Future<void> _addItem() async {
    final groceryItems = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );

    if (groceryItems == null) {
      return;
    }

    setState(() {
      _groceryItems.add(groceryItems);
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
