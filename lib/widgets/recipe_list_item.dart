// lib/widgets/recipe_list_item.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart'; // Import your Recipe model
import '../providers/recipe_provider.dart'; // Import your provider
import '../screens/recipe_detail_screen.dart'; // Import the detail screen
import 'edit_recipe_dialog.dart';

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
                const SizedBox(width: 12),
                const Icon(Icons.dinner_dining, size: 16),
                const SizedBox(width: 4),
                Text(recipe.cuisine),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Open the EditRecipeDialog as a pop-up
                showDialog(
                  context: context,
                  builder: (context) => EditRecipeDialog(recipe: recipe),
                );
              }, 
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // Optionally, show a confirmation dialog first.
                final success = await Provider.of<RecipeProvider>(context, listen: false)
                    .deleteRecipe(recipe.id);

                // Optionally, show a success/error message.
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${recipe.title} deleted.')),
                  );
                }
              },
            ),
          ],
        
        ),

        onTap: () {
          final int? recipeId = recipe.id;
          if (recipeId != null) {
            // CHANGED: Use showDialog instead of Navigator.push
            showDialog(
              context: context,
              builder: (context) => RecipeDetailDialog(recipeId: recipeId),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot open an unsaved recipe.')),
            );
          }
        }
      ),
    
    );
  }
}