// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Recipe> _recipes = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 15;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Recipe? _selectedRecipe;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _page = 1;
    _hasMore = true;
    _recipes = [];
    if (hasListeners) {
      notifyListeners();
    }

    try {
      final response = await _supabase
          .from('recipes')
          .select('*, recipes_meal_types(meal_types(meal_type))')
          .range((_page - 1) * _limit, _page * _limit - 1);
      
      final List<dynamic> data = response;
      _recipes = data.map((item) => Recipe.fromMap(item as Map<String, dynamic>)).toList();

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

  Future<void> fetchMoreRecipes() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _page++;
    if (hasListeners) {
      notifyListeners();
    }

    const minDisplayTime = Duration(milliseconds: 500);
    final startTime = DateTime.now();

    try {
      final response = await _supabase
          .from('recipes')
          .select('*, recipes_meal_types(meal_types(meal_type))')
          .range((_page - 1) * _limit, _page * _limit - 1);

      final networkTime = DateTime.now().difference(startTime);
      
      if (networkTime < minDisplayTime) {
        await Future.delayed(minDisplayTime - networkTime);
      }

      final List<dynamic> data = response;
      final newRecipes = data.map((item) => Recipe.fromMap(item as Map<String, dynamic>)).toList();
      
      _recipes.addAll(newRecipes);

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
      print('🚨 Error fetching recipe by ID: ${e.message}');
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
      print('🚨 Error adding recipe: ${e.message}');
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
      print('🚨 Error updating recipe: ${e.message}');
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
      print('🚨 Error deleting recipe: ${e.message}');
      return false;
    }
  }
}