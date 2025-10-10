import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;
  final Function(int id, Map<String, dynamic> updates) onUpdate;
  final Function(int id) onDelete;

  const RecipeListItem({
    super.key,
    required this.recipe,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            recipe.name.isNotEmpty ? recipe.name[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(recipe.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.cuisine),
            const SizedBox(height: 4),
            Text(recipe.instructions,
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                onUpdate(recipe.id, {'name': '${recipe.name} Updated'});
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(recipe.id),
            ),
          ],
        ),
      ),
    );
  }
}
