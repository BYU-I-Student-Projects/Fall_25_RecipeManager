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
  final String description;
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
    required this.description,
    required this.mealTypes, 
  });

  // Factory constructor to create a Recipe from a Supabase row (Map)
  factory Recipe.fromMap(Map<String, dynamic> json) {
    // Parse meal types from the joined data
    List<String> parsedMealTypes = [];
    if (json['recipes_meal_types'] != null) {
      final mealTypeRows = json['recipes_meal_types'] as List;
      parsedMealTypes = mealTypeRows
          .map((row) {
            // Handle the nested structure from Supabase
            if (row['meal_types'] != null && row['meal_types']['meal_type'] != null) {
              return row['meal_types']['meal_type'] as String;
            }
            return null;
          })
          .whereType<String>() // Filter out any null values
          .toList();
    }

    return Recipe(
      id: json['id'],
      title: json['name'] ?? '',
      ingredients: (json['ingredients'] ?? '').split(' , '),
      instructions: (json['instructions'] ?? '').split(' , '),
      prepTime: (json['pre-time-min'] as num?)?.toInt() ?? 0,
      cookTime: (json['cook-time-min'] as num?)?.toInt() ?? 0,
      calPerServing: (json['cal_per_serv'] as num?)?.toInt() ?? 0,
      servings: int.tryParse(json['servings'] ?? '') ?? 0,
      cuisine: json['cuisine'] ?? 'N/A',
      dietRestrictions: json['diet_restric'] ?? 'nan',
      description: json['description'] ?? 'No description.',
      mealTypes: parsedMealTypes.isEmpty ? ['All'] : parsedMealTypes, // Default to 'All' if empty
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
      'description': description,
      // Note: mealTypes are handled separately in the recipes_meal_types_rows table
      // They should be inserted/updated through that junction table
      // 'mealTypes': mealTypes,
      // Note: mealTypes are handled separately in the recipes_meal_types table
    };
  }
}