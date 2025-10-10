// lib/widgets/recipe_list_item.dart

import 'package:flutter/material.dart';
import '../models/recipe_model.dart'; // Import your Recipe model

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeListItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(

        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            recipe.title.isNotEmpty ? recipe.title[0] : '?',
            style: const TextStyle(color: Colors.white)
          ), 
        ),

        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              // recipe['description'],
              "[Description Placeholder]",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${recipe.cookTime} min'),
                const SizedBox(width: 12),
                const Icon(Icons.local_fire_department_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${recipe.calPerServing} kcal'),
              ],
            ),
          ],
        ),

        onTap: () {
          print('Tapped on ${recipe.title}');
          // TODO: Navigate to the recipe details screen
        },
      ),
    );
  }
}