// lib/services/grocery_helper.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class GroceryHelper {
  static final _supabase = Supabase.instance.client;

  // Category mapping based on common ingredient keywords
  static String suggestCategory(String ingredient) {
    final lower = ingredient.toLowerCase();

    // Produce
    if (lower.contains('lettuce') ||
        lower.contains('tomato') ||
        lower.contains('onion') ||
        lower.contains('garlic') ||
        lower.contains('potato') ||
        lower.contains('carrot') ||
        lower.contains('celery') ||
        lower.contains('pepper') ||
        lower.contains('spinach') ||
        lower.contains('broccoli') ||
        lower.contains('cucumber') ||
        lower.contains('avocado') ||
        lower.contains('mushroom') ||
        lower.contains('herb') ||
        lower.contains('basil') ||
        lower.contains('cilantro') ||
        lower.contains('parsley') ||
        lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('orange') ||
        lower.contains('lemon') ||
        lower.contains('lime') ||
        lower.contains('zucchini') ||
        lower.contains('kale')) {
      return 'Produce';
    }

    // Dairy
    if (lower.contains('milk') ||
        lower.contains('cheese') ||
        lower.contains('butter') ||
        lower.contains('cream') ||
        lower.contains('yogurt') ||
        lower.contains('sour cream') ||
        lower.contains('parmesan') ||
        lower.contains('mozzarella') ||
        lower.contains('cheddar') ||
        lower.contains('egg')) {
      return 'Dairy';
    }

    // Meat
    if (lower.contains('chicken') ||
        lower.contains('beef') ||
        lower.contains('pork') ||
        lower.contains('turkey') ||
        lower.contains('lamb') ||
        lower.contains('bacon') ||
        lower.contains('sausage') ||
        lower.contains('steak') ||
        lower.contains('ground') ||
        lower.contains('fish') ||
        lower.contains('salmon') ||
        lower.contains('shrimp') ||
        lower.contains('tuna')) {
      return 'Meat';
    }

    // Bakery
    if (lower.contains('bread') ||
        lower.contains('roll') ||
        lower.contains('bun') ||
        lower.contains('bagel') ||
        lower.contains('croissant') ||
        lower.contains('tortilla') ||
        lower.contains('pita')) {
      return 'Bakery';
    }

    // Pantry
    if (lower.contains('flour') ||
        lower.contains('sugar') ||
        lower.contains('salt') ||
        lower.contains('pepper') ||
        lower.contains('oil') ||
        lower.contains('olive oil') ||
        lower.contains('vinegar') ||
        lower.contains('sauce') ||
        lower.contains('paste') ||
        lower.contains('stock') ||
        lower.contains('broth') ||
        lower.contains('rice') ||
        lower.contains('pasta') ||
        lower.contains('noodle') ||
        lower.contains('bean') ||
        lower.contains('can') ||
        lower.contains('spice') ||
        lower.contains('seasoning')) {
      return 'Pantry';
    }

    // Frozen
    if (lower.contains('frozen') ||
        lower.contains('ice cream') ||
        lower.contains('popsicle')) {
      return 'Frozen';
    }

    // Beverages
    if (lower.contains('juice') ||
        lower.contains('soda') ||
        lower.contains('water') ||
        lower.contains('tea') ||
        lower.contains('coffee') ||
        lower.contains('wine') ||
        lower.contains('beer')) {
      return 'Beverages';
    }

    return 'Other';
  }

  // Parse ingredient to extract quantity and clean name
  static Map<String, String> parseIngredient(String ingredient) {
    ingredient = ingredient.trim();

    // Patterns to match measurements at the start
    final measurementPattern = RegExp(
      r'^(\d+(?:[\/\.\d]+)?)\s*(?:cup|cups|tablespoon|tablespoons|tbsp|tbs|teaspoon|teaspoons|tsp|pound|pounds|lb|lbs|ounce|ounces|oz|gram|grams|g|kg|kilogram|kilograms|ml|milliliter|milliliters|liter|liters|l)?s?\s+',
      caseSensitive: false,
    );

    final match = measurementPattern.firstMatch(ingredient);
    if (match != null) {
      final quantity = match.group(1) ?? '1';
      final name = ingredient.substring(match.end).trim();
      return {'quantity': quantity, 'name': name};
    }

    return {'quantity': '1', 'name': ingredient};
  }

  // Add ingredients to grocery list
  static Future<int> addIngredientsToGroceryList(
    BuildContext context,
    List<String> ingredients,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add items')),
        );
      }
      return 0;
    }

    int addedCount = 0;

    try {
      for (final ingredient in ingredients) {
        if (ingredient.trim().isEmpty) continue;

        final parsed = parseIngredient(ingredient);
        final category = suggestCategory(parsed['name']!);

        await _supabase.from('grocery_items').insert({
          'user_id': userId,
          'name': parsed['name'],
          'quantity': parsed['quantity'],
          'category': category,
          'checked': false,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        addedCount++;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $addedCount item${addedCount != 1 ? 's' : ''} to grocery list'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding ingredients: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding items: $e')),
        );
      }
    }

    return addedCount;
  }

  // Show dialog to select which ingredients to add
  static Future<void> showAddIngredientsDialog(
    BuildContext context,
    Recipe recipe,
  ) async {
    final selectedIngredients = <String>{};

    // Pre-select all ingredients
    for (final ingredient in recipe.ingredients) {
      if (ingredient.trim().isNotEmpty) {
        selectedIngredients.add(ingredient);
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add to Grocery List'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select ingredients to add:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedIngredients.addAll(recipe.ingredients);
                        });
                      },
                      child: const Text('Select All'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedIngredients.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = recipe.ingredients[index];
                      if (ingredient.trim().isEmpty) return const SizedBox();

                      final isSelected = selectedIngredients.contains(ingredient);

                      return CheckboxListTile(
                        dense: true,
                        value: isSelected,
                        title: Text(
                          ingredient,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedIngredients.add(ingredient);
                            } else {
                              selectedIngredients.remove(ingredient);
                            }
                          });
                        },
                        activeColor: const Color(0xFF839788),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF839788),
              ),
              onPressed: selectedIngredients.isEmpty
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);
                      await addIngredientsToGroceryList(
                        context,
                        selectedIngredients.toList(),
                      );
                    },
              child: Text(
                'Add ${selectedIngredients.length} item${selectedIngredients.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}