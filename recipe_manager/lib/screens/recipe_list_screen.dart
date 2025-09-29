// lib/screens/recipe_list_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe_model.dart';      
import '../widgets/recipe_list_item.dart'; 

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  // Create some dummy data to display
  final List<Recipe> recipes = [
    Recipe(title: 'Spaghetti Bolognese', description: 'A classic Italian dish', cookTime: 45),
    Recipe(title: 'Chicken Curry', description: 'Spicy and flavorful', cookTime: 30),
    Recipe(title: 'Pancakes', description: 'Perfect for breakfast', cookTime: 15),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (BuildContext context, int index) {
            return RecipeListItem(recipe: recipes[index]);
        },
      ),
    );
  }
}