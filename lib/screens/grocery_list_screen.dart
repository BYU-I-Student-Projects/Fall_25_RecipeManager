// lib/screens/grocery_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<Map<String, dynamic>> _groceryItems = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Other';
  String _sortBy = 'added'; // 'added', 'category', 'name'

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Bakery',
    'Pantry',
    'Frozen',
    'Beverages',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString('grocery_items');
    if (itemsJson != null) {
      setState(() {
        _groceryItems = List<Map<String, dynamic>>.from(
          json.decode(itemsJson).map((item) => Map<String, dynamic>.from(item)),
        );
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grocery_items', json.encode(_groceryItems));
  }

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _groceryItems.add({
          'name': _itemController.text,
          'quantity': _quantityController.text.isEmpty ? '1' : _quantityController.text,
          'category': _selectedCategory,
          'checked': false,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _itemController.clear();
        _quantityController.clear();
      });
      _saveItems();
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _groceryItems.removeAt(index);
    });
    _saveItems();
  }

  void _toggleCheck(int index) {
    setState(() {
      _groceryItems[index]['checked'] = !_groceryItems[index]['checked'];
    });
    _saveItems();
  }

  void _editItem(int index) {
    final item = _groceryItems[index];
    _itemController.text = item['name'];
    _quantityController.text = item['quantity'];
    _selectedCategory = item['category'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _itemController.clear();
              _quantityController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _groceryItems[index] = {
                  'name': _itemController.text,
                  'quantity': _quantityController.text.isEmpty ? '1' : _quantityController.text,
                  'category': _selectedCategory,
                  'checked': item['checked'],
                  'timestamp': item['timestamp'],
                };
              });
              _saveItems();
              _itemController.clear();
              _quantityController.clear();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Items'),
        content: const Text('Are you sure you want to remove all items from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _groceryItems.clear();
              });
              _saveItems();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSortedItems() {
    final items = List<Map<String, dynamic>>.from(_groceryItems);
    
    switch (_sortBy) {
      case 'category':
        items.sort((a, b) => a['category'].compareTo(b['category']));
        break;
      case 'name':
        items.sort((a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
        break;
      case 'added':
      default:
        items.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    }
    
    return items;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Produce':
        return Icons.local_florist;
      case 'Dairy':
        return Icons.opacity;
      case 'Meat':
        return Icons.set_meal;
      case 'Bakery':
        return Icons.bakery_dining;
      case 'Pantry':
        return Icons.kitchen;
      case 'Frozen':
        return Icons.ac_unit;
      case 'Beverages':
        return Icons.local_cafe;
      default:
        return Icons.shopping_basket;
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _getSortedItems();

    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF839788),
        title: const Text('My Grocery List'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'added', child: Text('Sort by: Date Added')),
              const PopupMenuItem(value: 'category', child: Text('Sort by: Category')),
              const PopupMenuItem(value: 'name', child: Text('Sort by: Name')),
            ],
          ),
          if (_groceryItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _itemController,
                        decoration: const InputDecoration(
                          hintText: 'Item name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          hintText: 'Qty',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(cat), size: 20),
                                const SizedBox(width: 8),
                                Text(cat),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF839788),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _groceryItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items yet!\nAdd something to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: sortedItems.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _groceryItems.removeAt(
                          _groceryItems.indexOf(sortedItems[oldIndex])
                        );
                        _groceryItems.insert(
                          _groceryItems.indexOf(sortedItems[newIndex > oldIndex ? newIndex : newIndex]),
                          item
                        );
                      });
                      _saveItems();
                    },
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      final actualIndex = _groceryItems.indexOf(item);
                      
                      return Dismissible(
                        key: Key('${item['timestamp']}'),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteItem(actualIndex),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          elevation: item['checked'] ? 0 : 2,
                          color: item['checked'] ? Colors.grey[300] : Colors.white,
                          child: ListTile(
                            leading: Checkbox(
                              value: item['checked'],
                              onChanged: (_) => _toggleCheck(actualIndex),
                              activeColor: const Color(0xFF839788),
                            ),
                            title: Text(
                              item['name'],
                              style: TextStyle(
                                decoration: item['checked']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item['checked'] ? Colors.grey : Colors.black,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(_getCategoryIcon(item['category']), size: 14),
                                const SizedBox(width: 4),
                                Text('${item['category']} • Qty: ${item['quantity']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editItem(actualIndex),
                                  color: const Color(0xFF839788),
                                ),
                                const Icon(Icons.drag_handle, color: Colors.grey),
                              ],
                            ),
                          ),
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