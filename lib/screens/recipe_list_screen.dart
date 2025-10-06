// lib/screens/recipe_list_screen.dart

import 'package:flutter/material.dart';
import '../widgets/recipe_list_item.dart';
import '../services/mock_recipe_service.dart';
import '../models/recipe_model.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate service and get the list of recipes
    final MockRecipeService mrs = MockRecipeService();
    final List<Recipe> recipes = mrs.getRecipes();

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (BuildContext context, int index) {
            // Get the specific recipe from the list by its index
            final recipe = recipes[index];
            // Pass the recipe object to list item widget
            return RecipeListItem(recipe: recipe);
          },
        ),
      ),
    );
  }
}