import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../widgets/recipe_list_item.dart';
import '../services/recipe_service.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<Recipe>> _futureRecipes;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    _futureRecipes = RecipeService().getRecipes();
  }

  void _updateRecipe(int id, Map<String, dynamic> updates) async {
    bool success = await RecipeService().updateRecipe(id, updates);
    if (success) {
      setState(() => _loadRecipes());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Recipe updated')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Update failed')));
    }
  }

  void _deleteRecipe(int id) async {
    bool success = await RecipeService().deleteRecipe(id);
    if (success) {
      setState(() => _loadRecipes());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Recipe deleted')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Recipe>>(
        future: _futureRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recipes = snapshot.data ?? [];

          return SafeArea(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeListItem(
                  recipe: recipe,
                  onUpdate: _updateRecipe,
                  onDelete: _deleteRecipe,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
