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

  // Store active filters
  String? _activeCuisineFilter;
  String? _activeMealTypeFilter;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore; // Getter for the new flag
  bool get hasMore => _hasMore;

  Recipe? _selectedRecipe;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  Future<void> fetchRecipes({String? cuisineFilter, String? mealTypeFilter}) async {
    _isLoading = true;
    _page = 1; // Reset to first page
    _hasMore = true;
    _recipes = [];
    _activeCuisineFilter = cuisineFilter;
    _activeMealTypeFilter = mealTypeFilter;
    
    if (hasListeners) {
      notifyListeners();
    }

    try {
      // Build the query with filters
      var query = _supabase
          .from('recipes')
          .select('*, recipes_meal_types(meal_types(meal_type))');

      // Apply cuisine filter if provided
      if (cuisineFilter != null && cuisineFilter != 'All') {
        query = query.or('cuisine.ilike.%$cuisineFilter%,diet_restric.ilike.%$cuisineFilter%');
      }

      // Apply range based on whether we're filtering
      final PostgrestTransformBuilder rangedQuery;
      if (mealTypeFilter != null && mealTypeFilter != 'All') {
        // Fetch more records to account for filtering
        rangedQuery = query.range(0, 200); // Fetch more when filtering
      } else {
        // Normal pagination
        rangedQuery = query.range((_page - 1) * _limit, _page * _limit - 1);
      }

      final response = await rangedQuery;
      
      final List<dynamic> data = response;
      var allRecipes = data.map((item) => Recipe.fromMap(item as Map<String, dynamic>)).toList();

      // Apply meal type filter in code (since Supabase join filtering is complex)
      if (mealTypeFilter != null && mealTypeFilter != 'All') {
        allRecipes = allRecipes.where((recipe) {
          return recipe.mealTypes.any((mealType) => 
            mealType.toLowerCase() == mealTypeFilter.toLowerCase()
          );
        }).toList();
      }

      _recipes = allRecipes;

      // Update hasMore based on filter state
      if (mealTypeFilter != null && mealTypeFilter != 'All') {
        _hasMore = false; // We fetched all filtered results
      } else if (data.length < _limit) {
        _hasMore = false;
      }
    } catch (error) {
      debugPrint('Error fetching recipes: $error');
    }

    _isLoading = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  // Fetch more recipes for infinite scrolling
  Future<void> fetchMoreRecipes() async {
    // Don't fetch more if we're filtering or already loading
    if (_isLoadingMore || !_hasMore || _activeMealTypeFilter != null || _activeCuisineFilter != null) {
      return;
    }

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
      debugPrint('Error fetching more recipes: $error');
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
      debugPrint('Error fetching recipe by ID: ${e.message}');
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<bool> addRecipe(Recipe newRecipe) async {
    // Get the current user ID
    final user = _supabase.auth.currentUser;
    // Check if user is logged in
    if (user == null) {
      debugPrint('🚨 Error adding recipe: User is not logged in.');
      return false;
    }

    // Get the recipe data from your object
    final Map<String, dynamic> recipeData = newRecipe.toMap();
    // Explicitly add the user_id to the map
    recipeData['user_uuid'] = user.id;

    // Insert the map
    try {
      await _supabase.from('recipes').insert(recipeData);
      // Refresh the local list of recipes
      await fetchRecipes();
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error adding recipe: ${e.message}');
      return false;
    }
  }

  Future<bool> updateRecipe(Recipe updatedRecipe) async {
    final int? recipeId = updatedRecipe.id;
    if (recipeId == null) {
      debugPrint('🚨 Error updating recipe: Recipe has a null ID.');
      return false;
    }
    try {
      await _supabase
          .from('recipes')
          .update(updatedRecipe.toMap())
          .eq('id', recipeId);

      final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);

      if (index != -1) {
        _recipes[index] = updatedRecipe;
        notifyListeners();
      }

      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error updating recipe: ${e.message}');
      return false;
    }
  }

  Future<bool> deleteRecipe(int? id) async {
    if (id == null) {
      debugPrint('🚨 Error: Tried to delete a recipe with a null ID.');
      return false;
    }
    try {
      await _supabase.from('recipes').delete().match({'id': id});
      _recipes.removeWhere((recipe) => recipe.id == id);
      await fetchRecipes();
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error deleting recipe: ${e.message}');
      return false;
    }
  }
}