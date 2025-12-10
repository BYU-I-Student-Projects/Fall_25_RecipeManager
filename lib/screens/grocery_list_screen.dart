// lib/screens/grocery_list_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------
// Custom Grab Handle
// ---------------------
class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    final color = Colors.grey.shade400;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 3,
          margin: const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _groceryItems = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Other';
  String _sortBy = 'added';
  bool _isLoading = true;

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

  // Get current user ID
  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> _loadItems() async {
    if (_userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _supabase
          .from('grocery_items')
          .select()
          .eq('user_id', _userId!)
          .order('timestamp', ascending: true);

      setState(() {
        _groceryItems = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading grocery items: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  Future<void> _addItem() async {
    if (_itemController.text.trim().isEmpty || _userId == null) return;

    int qty = int.tryParse(_quantityController.text) ?? 1;
    if (qty < 1) qty = 1;

    final newItem = {
      'user_id': _userId,
      'name': _itemController.text.trim(),
      'quantity': qty.toString(),
      'category': _selectedCategory,
      'checked': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      final response = await _supabase
          .from('grocery_items')
          .insert(newItem)
          .select()
          .single();

      setState(() {
        _groceryItems.add(response);
      });

      _itemController.clear();
      _quantityController.clear();
    } catch (e) {
      debugPrint('Error adding item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = _groceryItems[index];
    final itemId = item['id'];

    try {
      await _supabase.from('grocery_items').delete().eq('id', itemId);

      setState(() {
        _groceryItems.removeAt(index);
      });
    } catch (e) {
      debugPrint('Error deleting item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  Future<void> _toggleCheck(int index) async {
    final item = _groceryItems[index];
    final itemId = item['id'];
    final newCheckedState = !item['checked'];

    try {
      await _supabase
          .from('grocery_items')
          .update({'checked': newCheckedState}).eq('id', itemId);

      setState(() {
        _groceryItems[index]['checked'] = newCheckedState;
      });
    } catch (e) {
      debugPrint('Error toggling check: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  void _editItem(int index) {
    final original = _groceryItems[index];

    final nameController = TextEditingController(text: original['name']);
    final qtyController = TextEditingController(text: original['quantity']);
    String editCategory = original['category'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: editCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    editCategory = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                int qty = int.tryParse(qtyController.text) ?? 1;
                if (qty < 1) qty = 1;

                final itemId = original['id'];

                try {
                  await _supabase.from('grocery_items').update({
                    'name': nameController.text.trim(),
                    'quantity': qty.toString(),
                    'category': editCategory,
                  }).eq('id', itemId);

                  setState(() {
                    _groceryItems[index] = {
                      ...original,
                      'name': nameController.text.trim(),
                      'quantity': qty.toString(),
                      'category': editCategory,
                    };
                  });

                  Navigator.pop(context);
                } catch (e) {
                  debugPrint('Error updating item: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating item: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Items'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true || _userId == null) return;

    try {
      await _supabase.from('grocery_items').delete().eq('user_id', _userId!);

      setState(() {
        _groceryItems.clear();
      });
    } catch (e) {
      debugPrint('Error clearing all items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing items: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getSortedItems() {
    final list = List<Map<String, dynamic>>.from(_groceryItems);

    switch (_sortBy) {
      case 'category':
        list.sort((a, b) => a['category'].compareTo(b['category']));
        break;
      case 'name':
        list.sort((a, b) =>
            a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
        break;
      default:
        list.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    }

    return list;
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEE0CB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEE0CB),
        body: Center(
          child: Text(
            'Please log in to view your grocery list',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final sortedItems = _getSortedItems();

    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF839788),
        title: const Text('My Grocery List'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'added', child: Text('Sort by: Date Added')),
              PopupMenuItem(
                  value: 'category', child: Text('Sort by: Category')),
              PopupMenuItem(value: 'name', child: Text('Sort by: Name')),
            ],
          ),
          if (_groceryItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // ---------- ADD ITEM UI ----------
          Padding(
            padding: const EdgeInsets.all(16),
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
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Row(
                                    children: [
                                      Icon(_getCategoryIcon(cat), size: 20),
                                      const SizedBox(width: 8),
                                      Text(cat),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value!),
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

          // ---------- LIST ----------
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
                    buildDefaultDragHandles: false,
                    itemCount: sortedItems.length,
                    onReorder: (oldIndex, newIndex) async {
                      final sorted = _getSortedItems();
                      final movedItem = sorted[oldIndex];

                      if (newIndex > oldIndex) newIndex--;

                      _groceryItems.remove(movedItem);

                      if (newIndex >= sorted.length) {
                        _groceryItems.add(movedItem);
                      } else {
                        final target = sorted[newIndex];
                        final targetIndex = _groceryItems.indexOf(target);
                        _groceryItems.insert(targetIndex, movedItem);
                      }

                      // Update timestamps to maintain order
                      for (int i = 0; i < _groceryItems.length; i++) {
                        final newTimestamp =
                            DateTime.now().millisecondsSinceEpoch + i;
                        _groceryItems[i]['timestamp'] = newTimestamp;

                        // Update in database
                        try {
                          await _supabase.from('grocery_items').update({
                            'timestamp': newTimestamp,
                          }).eq('id', _groceryItems[i]['id']);
                        } catch (e) {
                          debugPrint('Error updating order: $e');
                        }
                      }

                      setState(() {});
                    },
                    itemBuilder: (_, index) {
                      final item = sortedItems[index];
                      final actualIndex = _groceryItems.indexOf(item);

                      return Dismissible(
                        key: Key(item['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteItem(actualIndex),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          elevation: item['checked'] ? 0 : 2,
                          color:
                              item['checked'] ? Colors.grey[300] : Colors.white,
                          child: ListTile(
                            leading: Checkbox(
                              value: item['checked'],
                              activeColor: const Color(0xFF839788),
                              onChanged: (_) => _toggleCheck(actualIndex),
                            ),
                            title: Text(
                              item['name'],
                              style: TextStyle(
                                decoration: item['checked']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: item['checked']
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(_getCategoryIcon(item['category']),
                                    size: 14),
                                const SizedBox(width: 4),
                                Text(
                                    '${item['category']} • Qty: ${item['quantity']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: const Color(0xFF839788),
                                  onPressed: () => _editItem(actualIndex),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: _GrabHandle(),
                                  ),
                                ),
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
