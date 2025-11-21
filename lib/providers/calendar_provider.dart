import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_model.dart';

class MealDayProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<MealDay> _meals = [];
  bool _isLoading = false;

  List<MealDay> get meals => _meals;
  bool get isLoading => _isLoading;

  // Fetch all meals
  Future<void> fetchMeals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.from('meal_day_list').select();
      final List data = response;
      _meals = data.map((item) => MealDay.fromMap(item)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching meals: $e');
    }

    _isLoading = false;
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
    mealData['user_id'] = user.id; // Asegurarse de asignar el user_id actual

    try {
      await _supabase.from('meal_day_list').insert(mealData);
      await fetchMeals(); // Actualiza la lista local
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
          .from('meal_day_list')
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
      await _supabase.from('meal_day_list').delete().eq('id_meal', idMeal);
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
          .from('meal_day_list')
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
