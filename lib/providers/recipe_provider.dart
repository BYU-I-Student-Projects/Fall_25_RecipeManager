// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart'; // Import your model

class RecipeProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Method to fetch all recipes from Supabase
  Future<void> fetchRecipes() async {
    _isLoading = true;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      final response = await _supabase.from('recipes').select();
      final List<dynamic> data = response;
      _recipes = data.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
    } catch (error) {
      debugPrint('AN ERROR OCCURRED: $error');
    }

    _isLoading = false;

    if (hasListeners) {
      notifyListeners();
    }
  }

  // You would add other methods here for CRUD operations
  // Future<void> addRecipe(Recipe newRecipe) { ... }
  // Future<void> deleteRecipe(int id) { ... }
}