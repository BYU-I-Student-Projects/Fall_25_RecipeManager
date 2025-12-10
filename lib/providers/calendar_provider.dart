import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_model.dart';
import '../models/recipe_model.dart';

class MealDayProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<MealDay> _meals = [];
  bool _isLoading = false;

  // Recipes available for assignment in the calendar
  List<Recipe> _recipes = [];
  bool _isLoadingRecipes = false;

  // Map of meal_type -> list of recipes (e.g., 'Breakfast' -> [Recipe1, Recipe2])
  Map<String, List<Recipe>> _recipesByMealType = {};

  List<MealDay> get meals => _meals;
  bool get isLoading => _isLoading;

  List<Recipe> get recipes => _recipes;
  bool get isLoadingRecipes => _isLoadingRecipes;

  // List of available meal types based on what comes from the DB
  List<String> get availableMealTypes =>
      _recipesByMealType.keys.toList()..sort();

  // Get recipes for a specific meal type
  List<Recipe> recipesForMealType(String mealType) {
    return _recipesByMealType[mealType] ?? [];
  }

  // Fetch all meals assigned to specific days
  Future<void> fetchMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.from('meal-day-list').select();
      final List data = response;
      _meals = data.map((item) => MealDay.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching meals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Rebuilds the _recipesByMealType map from _recipes
  void _buildRecipesByMealType() {
    final Map<String, List<Recipe>> map = {};

    for (final recipe in _recipes) {
      for (final rawType in recipe.mealTypes) {
        final key = rawType.trim();
        if (key.isEmpty || key.toLowerCase() == 'all') continue;
        map.putIfAbsent(key, () => []).add(recipe);
      }
    }

    _recipesByMealType = map;
  }

  // Fetch all recipes with their meal types (for use in the calendar)
  Future<void> fetchCalendarRecipes() async {
    _isLoadingRecipes = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('recipes')
          .select('*, recipes_meal_types(meal_types(meal_type))');

      final List data = response;
      _recipes = data
          .map((item) => Recipe.fromMap(item as Map<String, dynamic>))
          .toList();

      _buildRecipesByMealType();
    } catch (e) {
      debugPrint('❌ Error fetching calendar recipes: $e');
    }

    _isLoadingRecipes = false;
    notifyListeners();
  }

  // Add a new meal
  Future<bool> addMeal(MealDay meal) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ Error: User not logged in');
      return false;
    }

    final mealData = meal.toMap();
    mealData['user_id'] = user.id; // Ensure current user_id is assigned

    try {
      await _supabase.from('meal-day-list').insert(mealData);
      await fetchMeals(); // Updates local list
      return true;
    } catch (e) {
      debugPrint('❌ Error adding meal: $e');
      return false;
    }
  }

  // Update a meal
  Future<bool> updateMeal(MealDay meal) async {
    if (meal.idMeal.isEmpty) return false;

    try {
      await _supabase
          .from('meal-day-list')
          .update(meal.toMap())
          .eq('id_meal', meal.idMeal);

      final index = _meals.indexWhere((m) => m.idMeal == meal.idMeal);
      if (index != -1) {
        _meals[index] = meal;
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error updating meal: $e');
      return false;
    }
  }

  // Delete a meal
  Future<bool> deleteMeal(String idMeal) async {
    try {
      await _supabase.from('meal-day-list').delete().eq('id_meal', idMeal);
      _meals.removeWhere((m) => m.idMeal == idMeal);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting meal: $e');
      return false;
    }
  }

  // Fetch a single meal by ID
  Future<MealDay?> fetchMealById(String idMeal) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('meal-day-list')
          .select()
          .eq('id_meal', idMeal)
          .single();

      return MealDay.fromMap(response);
    } catch (e) {
      debugPrint('❌ Error fetching meal by ID: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}