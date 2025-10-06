// lib/models/recipe_model.dart

class Recipe {
  final int id;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final String description;
  final int cookTime; // in minutes
  final int calories;
  final String? imageUrl; // URL for recipe image (optional)

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.description,
    required this.cookTime,
    required this.calories,
    this.imageUrl,
  });
}