class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final String instructions;
  final String cuisine;
  final double prepTime; // minutes
  final double cookTime; // minutes
  final double calories; // per serving
  final String? dietRestriction;
  final int? servings;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.cuisine,
    required this.prepTime,
    required this.cookTime,
    required this.calories,
    this.dietRestriction,
    this.servings,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    List<String> normalizeList(dynamic field) {
      if (field == null) return [];
      if (field is List) return field.map((e) => e.toString()).toList();
      if (field is String) {
        // Split comma- or newline-separated text into list
        return field.split(RegExp(r'[,\\n]')).map((e) => e.trim()).toList();
      }
      return [];
    }

    return Recipe(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Untitled',
      ingredients: normalizeList(map['ingredients']),
      instructions: map['instructions']?.toString() ?? '', // <-- fixed type
      prepTime: (map['pre-time-min'] ?? 0).toDouble(),
      cookTime: (map['cook-time-min'] ?? 0).toDouble(),
      calories: (map['cal_per_serv'] ?? 0).toDouble(),
      cuisine: map['cuisine'] ?? '',
      servings: int.tryParse(map['servings']?.toString() ?? ''),
      dietRestriction: map['diet_restric']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.join(', '),
      'instructions': instructions,
      'cuisine': cuisine,
      'pre-time-min': prepTime,
      'cook-time-min': cookTime,
      'cal_per_serv': calories,
      'diet_restric': dietRestriction,
      'servings': servings?.toString(),
    };
  }
}
