// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the recipe when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipeById(widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider for changes
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // Show title only when recipe is loaded
        title: Text(recipeProvider.selectedRecipe?.title ?? 'Loading...'),
      ),
      body: recipeProvider.isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : recipeProvider.selectedRecipe == null
              ? const Center(child: Text('Recipe not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingredients:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      // Display your recipe details here
                      Text(recipeProvider.selectedRecipe!.ingredients.join('\n')),
                      // TODO: Add more details like instructions, prep time, etc.
                    ],
                  ),
                ),
    );
  }
}