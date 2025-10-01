// lib/models/recipe_model.dart

class Recipe {
  final String title;
  final String description;
  final int cookTime; // In minutes

  Recipe({
    required this.title,
    required this.description,
    required this.cookTime,
  });
}