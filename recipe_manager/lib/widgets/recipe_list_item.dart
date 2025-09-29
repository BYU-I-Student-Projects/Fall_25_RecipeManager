// lib/widgets/recipe_list_item.dart

import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeListItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(recipe.title),
      subtitle: Text(recipe.description),
      trailing: Text('${recipe.cookTime} min'),
    );
  }
}