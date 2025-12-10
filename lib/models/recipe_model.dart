// lib/models/recipe_model.dart
class Recipe {
  final int? id;
  final String title;
  final List<String> ingredients; 
  final List<String> instructions;
  final int prepTime; // In minutes
  final int cookTime; // In minutes
  final int servings;
  final int calPerServing;
  final String cuisine; // e.g., Italian, Chinese
  final String dietRestrictions; // e.g., Vegan, Gluten-Free
  final List<String> mealTypes;

  Recipe({
    this.id,
    required this.title,
    required this.ingredients, 
    required this.instructions,
    required this.prepTime, 
    required this.cookTime, 
    required this.servings,
    required this.calPerServing,
    required this.cuisine,
    required this.dietRestrictions,
    required this.mealTypes, 
  });

  // Factory constructor to create a Recipe from a Supabase row (Map)
  factory Recipe.fromMap(Map<String, dynamic> json) {
    // 1. Helper for parsing numbers that might come as Strings or Nums
    int parseSafeInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // 2. Parse the nested meal types safely
    List<String> parsedMealTypes = [];
    if (json['recipes_meal_types'] != null && json['recipes_meal_types'] is List) {
      parsedMealTypes = (json['recipes_meal_types'] as List)
          .map((row) {
            if (row is Map && row['meal_types'] != null && row['meal_types']['meal_type'] != null) {
              return row['meal_types']['meal_type'] as String;
            }
            return null;
          })
          .whereType<String>()
          .toList();
    }

    return Recipe(
      id: json['id'],
      title: json['name'] ?? '',
      ingredients: (json['ingredients'] ?? '').toString().split(' , '),
      instructions: (json['instructions'] ?? '').toString().split(' , '),
      // 3. Use the helper for ALL numeric fields
      prepTime: parseSafeInt(json['pre-time-min']),
      cookTime: parseSafeInt(json['cook-time-min']),
      calPerServing: parseSafeInt(json['cal_per_serv']), // This is numeric in your schema!
      servings: int.tryParse(json['servings']?.toString() ?? '') ?? 0,
      cuisine: json['cuisine'] ?? 'N/A',
      dietRestrictions: json['diet_restric'] ?? 'nan',
      mealTypes: parsedMealTypes.isEmpty ? ['All'] : parsedMealTypes,
    );
  }

  String get name => title; 

  // Method to convert a Recipe object back to a Map.
  // Useful for INSERT and UPDATE operations.
  Map<String, dynamic> toMap() {
    return {
      'name': title,
      'ingredients': ingredients.join(' , '),
      'instructions': instructions.join(' , '),
      'pre-time-min': prepTime,
      'cook-time-min': cookTime,
      'cal_per_serv': calPerServing,
      'servings': servings.toString(),
      'cuisine': cuisine,
      'diet_restric': dietRestrictions,
      // Note: mealTypes are handled separately in the recipes_meal_types table
    };
  }
}