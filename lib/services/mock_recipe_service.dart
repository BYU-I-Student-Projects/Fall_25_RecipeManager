import '../models/recipe_model.dart';

class MockRecipeService {
  final List<Recipe> _recipes = [
    Recipe(
      id: 1,
      name: 'Pork Tenderloin',
      ingredients: [
        'Pork Tenderloin',
        'Smoked Paprika',
        'Minced Garlic',
        'Salt',
        'Black Pepper',
        'Stock or Orange Juice',
        'Sugar',
        'Butter'
      ],
      instructions:
          'Rub the tenderloin with Smoked Paprika, Minced Garlic, Salt, Black Pepper, and Marinade Pork for 24 hours. Sear on all sides, then put in an oven until the pork registers 145ºF. Pull pork and make pan sauce with fond, stock/juice, sugar, and pad of butter. Whisk to combine, and serve',
      cuisine: 'Italian',
      prepTime: 10,
      cookTime: 60,
      calories: 600,
      dietRestriction: null,
      servings: 2,
    ),
    Recipe(
      id: 2,
      name: 'Spaghetti Carbonara',
      ingredients: ['Pasta', 'Eggs', 'Bacon'],
      instructions: 'Boil pasta, mix eggs, and combine everything.',
      cuisine: 'Italian',
      prepTime: 10,
      cookTime: 20,
      calories: 600,
      dietRestriction: null,
      servings: 2,
    ),
    // … other recipes …
  ];

  List<Recipe> getRecipes() => List.unmodifiable(_recipes);

  Recipe getRecipeById(int id) =>
      _recipes.firstWhere((recipe) => recipe.id == id);

  bool updateRecipe(int id, Recipe updatedRecipe) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);
    if (index == -1) return false;
    _recipes[index] = updatedRecipe;
    return true;
  }

  bool deleteRecipe(int id) {
    final initialLength = _recipes.length;
    _recipes.removeWhere((recipe) => recipe.id == id);
    return _recipes.length < initialLength;
  }

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
  }
}
