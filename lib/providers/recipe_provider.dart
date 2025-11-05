// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
final _supabase = Supabase.instance.client;
  List<Recipe> _recipes = [];
  
  // Use two separate flags for different loading states
  bool _isLoading = false;      // For the initial, full-screen load
  bool _isLoadingMore = false;  // For loading more items at the bottom

  bool _hasMore = true;
  int _page = 1;
  final int _limit = 15;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore; // Getter for the new flag
  bool get hasMore => _hasMore;

  Recipe? _selectedRecipe;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _page = 1; // Reset to first page
    _hasMore = true;
    _recipes = []; // Clear existing recipes
    if (hasListeners) {
      notifyListeners();
    }

    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .range((_page - 1) * _limit, _page * _limit - 1); // Fetch first 15
      final List<dynamic> data = response;
      _recipes = data.map((item) => Recipe.fromMap(item as Map<String, dynamic>)).toList();

      // If we received fewer recipes than the limit, we've reached the end
      if (data.length < _limit) {
        _hasMore = false;
      }
    } catch (error) {
      debugPrint('AN ERROR OCCURRED: $error');
    }

    _isLoading = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Fetch more recipes for infinite scrolling
  Future<void> fetchMoreRecipes() async {
    // Don't fetch if we're already loading or if there are no more recipes
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _page++; // Go to the next page
    if (hasListeners) {
      notifyListeners();
    }

    // Define a minimum display time for the loading indicator
    const minDisplayTime = Duration(milliseconds: 500);
    final startTime = DateTime.now();

    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .range((_page - 1) * _limit, _page * _limit - 1); // Fetch the next batch

      // Calculate how long the network request took
      final networkTime = DateTime.now().difference(startTime);
      
      // If the request was faster than our minimum, wait the remaining time
      if (networkTime < minDisplayTime) {
        await Future.delayed(minDisplayTime - networkTime);
      }

      final List<dynamic> data = response;
      final newRecipes = data.map((item) => Recipe.fromMap(item as Map<String, dynamic>)).toList();
      
      _recipes.addAll(newRecipes); // Add the new recipes to the existing list

      // If we received fewer recipes than the limit, we've reached the end
      if (newRecipes.length < _limit) {
        _hasMore = false;
      }

    } catch (error) {
      debugPrint('AN ERROR OCCURRED fetching more recipes: $error');
    }

    _isLoadingMore = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Fetch a single recipe by its ID
  Future<void> fetchRecipeById(int id) async {
    _isLoadingDetails = true;
    _selectedRecipe = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('recipes')
          .select('*, recipes_meal_types(meal_types(meal_type))')
          .eq('id', id)
          .single();

      _selectedRecipe = Recipe.fromMap(response);
    } on PostgrestException catch (e) {
      debugPrint('🚨 Error fetching recipe by ID: ${e.message}');
      // Handle the error, maybe set an error state
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<bool> addRecipe(Recipe newRecipe) async {
    try {
      await _supabase.from('recipes').insert([newRecipe.toMap()]);
      await fetchRecipes();
      return true;
    } on PostgrestException catch (e) {
      debugPrint('🚨 Error adding recipe: ${e.message}');
      return false;
    }
  }

  Future<bool> updateRecipe(Recipe updatedRecipe) async {
    try {
      await _supabase
          .from('recipes')
          .update(updatedRecipe.toMap())
          .eq('id', updatedRecipe.id);

      final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);

      if (index != -1) {
        _recipes[index] = updatedRecipe;
        notifyListeners();
      }

      return true;
    } on PostgrestException catch (e) {
      debugPrint('🚨 Error updating recipe: ${e.message}');
      return false;
    }
  }

  Future<bool> deleteRecipe(int id) async {
    try {
      await _supabase.from('recipes').delete().eq('id', id);
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      debugPrint('🚨 Error deleting recipe: ${e.message}');
      return false;
    }
  }
}