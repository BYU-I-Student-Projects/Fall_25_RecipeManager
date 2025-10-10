// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart'; // Import your model

class RecipeProvider with ChangeNotifier {
  // Initialize Supabase client
  final _supabase = Supabase.instance.client;
  List<Recipe> _recipes = [];

  // Recipe list state
  List<Recipe> get recipes => _recipes;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Single recipe detail state
  Recipe? _selectedRecipe;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  // Fetch all recipes from Supabase
  Future<void> fetchRecipes() async {
    // Set loading to true and notify listeners
    _isLoading = true;
    if (hasListeners) {
      notifyListeners();
    }

    // Fetch data from the 'recipes' table
    try {
      final response = await _supabase.from('recipes').select();
      final List<dynamic> data = response;
      // Maps the data to a list of Recipe objects
      _recipes = data.map((item) => Recipe.fromMap(item as Map<String, dynamic>)).toList();
    } catch (error) {
      debugPrint('AN ERROR OCCURRED: $error');
    }

    // Set loading to false and notify listeners
    _isLoading = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Fetch a single recipe by its ID
  Future<void> fetchRecipeById(int id) async {
    _isLoadingDetails = true;
    _selectedRecipe = null; // Clear previous recipe
    notifyListeners();

    try {
      final response =
          await _supabase.from('recipes').select().eq('id', id).single();

      // Store the fetched recipe
      _selectedRecipe = Recipe.fromMap(response);
    } on PostgrestException catch (e) {
      print('🚨 Error fetching recipe by ID: ${e.message}');
      // Handle the error, maybe set an error state
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// ********************************************
  /// Add, Update, Delete Recipe Methods
  /// **********************************************
  
  // Add a new recipe
  Future<bool> addRecipe(Recipe newRecipe) async {
    try {
      // The insert method in Supabase's Dart client expects a List of Maps.
      // .toJson() converts our Recipe object into the required Map format.
      await _supabase.from('recipes').insert([newRecipe.toMap()]);

      // After adding, refresh the main recipe list to include the new one.
      await fetchRecipes();

      return true;
    } on PostgrestException catch (e) {
      print('🚨 Error adding recipe: ${e.message}');
      return false;
    }
  }

  // Update an existing recipe
  Future<bool> updateRecipe(Recipe updatedRecipe) async {
    try {
      await _supabase
          .from('recipes')
          .update(updatedRecipe.toMap())
          .eq('id', updatedRecipe.id);

      // Find the index of the old recipe in our local list.
      final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);

      // If found, replace it with the updated recipe.
      if (index != -1) {
        _recipes[index] = updatedRecipe;
        notifyListeners(); // Tell the UI to rebuild.
      }

      return true;
    } on PostgrestException catch (e) {
      print('🚨 Error updating recipe: ${e.message}');
      return false;
    }
  }

  // Delete a recipe by its ID
  Future<bool> deleteRecipe(int id) async {
    try {
      await _supabase.from('recipes').delete().eq('id', id);

      // Remove the recipe from the local list.
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners(); // Tell the UI to rebuild.

      return true;
    } on PostgrestException catch (e) {
      print('🚨 Error deleting recipe: ${e.message}');
      return false;
    }
  }
}