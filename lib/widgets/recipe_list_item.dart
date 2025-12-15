// lib/widgets/recipe_list_item.dart

import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../screens/recipe_detail_screen.dart';
import '../widgets/grocery_helper.dart';

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeListItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      // Removed the duplicate ListTile child and Invalid onTap here.
      // Kept the custom InkWell layout.
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => RecipeDetailDialog(recipeId: recipe.id!),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Quick Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF839788),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    color: const Color(0xFF839788),
                    iconSize: 24,
                    onPressed: () {
                      GroceryHelper.showAddIngredientsDialog(context, recipe);
                    },
                    tooltip: 'Add to Grocery List',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Cuisine and Diet
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFD7EA).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recipe.cuisine,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (recipe.dietRestrictions.toLowerCase() != 'nan')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAA898).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe.dietRestrictions,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick Info
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildInfoItem(
                      Icons.schedule, '${recipe.prepTime + recipe.cookTime} min'),
                  _buildInfoItem(Icons.restaurant, '${recipe.servings} servings'),
                  _buildInfoItem(Icons.local_fire_department,
                      '${recipe.calPerServing} cal'),
                ],
              ),

              // Meal Types
              if (recipe.mealTypes.isNotEmpty &&
                  !(recipe.mealTypes.length == 1 &&
                      recipe.mealTypes[0] == 'All'))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: recipe.mealTypes.map((mealType) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mealType,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}