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
  final _scrollController = ScrollController();

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

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // A threshold helps trigger the fetch before the user hits the absolute bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<RecipeProvider>(context, listen: false).fetchMoreRecipes();
    }
  }
  @override
  Widget build(BuildContext context) {
    // Access the provider. The widget will rebuild when notifyListeners is called.
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF839788),
        title: const Text('My Recipes'),
      ),
      body: SafeArea(
        // Check the isLoading flag from the provider
        child: recipeProvider.isLoading && recipeProvider.recipes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: recipeProvider.recipes.length + (recipeProvider.hasMore ? 1 : 0),
                itemBuilder: ((context, index) {
                  // Check if we are at the end of the list
                  if (index == recipeProvider.recipes.length) {
                    // Only show the bottom indicator if we're loading more
                    return recipeProvider.isLoadingMore
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                      : const SizedBox.shrink(); // Otherwise, show an empty box
                  }
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