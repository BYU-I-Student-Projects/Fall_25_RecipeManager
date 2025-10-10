import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Recipe>> getRecipes() async {
    final data = await _client.from('recipes').select();

    return data.map((item) => Recipe.fromMap(item)).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    try {
      final response =
          await _client.from('recipes').select().eq('id', id).single();
      return Recipe.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Error fetching recipe by ID: ${e.message}');
    }
  }

  Future<bool> updateRecipe(int id, Map<String, dynamic> updatedFields) async {
    try {
      await _client.from('recipes').update(updatedFields).eq('id', id);
      return true;
    } on PostgrestException catch (e) {
      throw Exception('Error updating recipe: ${e.message}');
    }
  }

  Future<bool> deleteRecipe(int id) async {
    try {
      await _client.from('recipes').delete().eq('id', id);
      return true;
    } on PostgrestException catch (e) {
      throw Exception('Error deleting recipe: ${e.message}');
    }
  }

  Future<bool> addRecipe(Recipe recipe) async {
    try {
      await _client.from('recipes').insert([recipe.toMap()]);
      return true;
    } on PostgrestException catch (e) {
      throw Exception('Error adding recipe: ${e.message}');
    }
  }
}
