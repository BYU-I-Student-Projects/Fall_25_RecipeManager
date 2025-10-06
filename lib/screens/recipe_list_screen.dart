// lib/screens/recipe_list_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/recipe_list_item.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  // Constructs a query to fetch recipes from the 'recipes' table in Supabase
  final _future = Supabase.instance.client
      .from('recipes')
      .select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipes = snapshot.data!;
          return SafeArea(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: ((context, index) {
                // Get the specific recipe from the list by its index
                final recipe = recipes[index];
                // Pass the recipe object to list item widget
                return RecipeListItem(recipe: recipe);
              }),
            ),
          );
        }
      ),
    );
  }
}