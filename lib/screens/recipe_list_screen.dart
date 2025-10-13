// lib/screens/recipe_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_list_item.dart';
import '../models/recipe_model.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access context
    // This calls fetchRecipes() right after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check to ensure the widget is still on-screen
      // before attempting to access the context or call the provider.
      if (mounted) {
        Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider. The widget will rebuild when notifyListeners is called.
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      body: SafeArea(
        // Check the isLoading flag from the provider
        child: recipeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: recipeProvider.recipes.length,
                itemBuilder: ((context, index) {
                  // Get the specific recipe object from the provider's list
                  final Recipe recipe = recipeProvider.recipes[index];
                  
                  // Pass the Recipe object to your list item widget
                  return RecipeListItem(recipe: recipe);
                }),
              ),
      ),
    );
  }
}