// lib/models/recipe_model.dart
class Recipe {
  final int id; 
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
    required this.id,
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
    // Debug: Print the raw JSON to see the structure
    print('🔍 Recipe JSON: ${json.keys}');
    print('🔍 Meal types data: ${json['recipes_meal_types']}');
    
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
    
    print('🔍 Parsed meal types: $parsedMealTypes');

    return Recipe(
      id: json['id'],
      title: json['name'] ?? '', // Default to empty string if null
      // Splitting the 'text' column into a List<String>
      ingredients: (json['ingredients'] ?? '').split(' , '),
      instructions: (json['instructions'] ?? '').split(' , '),
      // Converting 'numeric' from DB to 'int' in Dart.
      // Supabase may return numeric types as 'num' or 'double'.
      prepTime: (json['pre-time-min'] as num?)?.toInt() ?? 0,
      cookTime: (json['cook-time-min'] as num?)?.toInt() ?? 0,
      calPerServing: (json['cal_per_serv'] as num?)?.toInt() ?? 0,
      // Converting 'text' from DB to 'int' in Dart.
      // This requires parsing the string. Using tryParse is safer.
      servings: int.tryParse(json['servings'] ?? '') ?? 0,
      cuisine: json['cuisine'] ?? 'N/A',
      dietRestrictions: json['diet_restric'] ?? 'nan',
      mealTypes: parsedMealTypes.isEmpty ? ['All'] : parsedMealTypes, // Default to 'All' if empty
    );
  }

  String get name => title; 

  // Method to convert a Recipe object back to a Map.
  // Useful for INSERT and UPDATE operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title,
      // Joining the List<String> back into a single 'text' string.
      'ingredients': ingredients.join(' , '),
      'instructions': instructions.join(' , '),
      'pre-time-min': prepTime,
      'cook-time-min': cookTime,
      'cal_per_serv': calPerServing,
      'servings': servings.toString(),
      'cuisine': cuisine,
      'diet_restric': dietRestrictions,
      // Note: mealTypes are handled separately in the recipes_meal_types_rows table
      // They should be inserted/updated through that junction table
    };
  }
}