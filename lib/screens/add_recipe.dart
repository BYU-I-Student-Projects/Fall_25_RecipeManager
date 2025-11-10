import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipeToEdit;

  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  // main field controllers
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState(); 
    // If a recipe was passed in, prefill the controllers for editing
    final recipe = widget.recipeToEdit;
    if (recipe != null) {
      //show lists on seperate lines for ease of editing
      _instructionsController.text = recipe.instructions.join('\n');
      _ingredientsController.text = recipe.ingredients.join('\n');
      _prepTimeController.text = recipe.prepTime.toString();
      _cookTimeController.text = recipe.cookTime.toString();
      _caloriesController.text = recipe.calPerServing.toString();
    }
  }

  // free memory
  @override
  void dispose() {
    _instructionsController.dispose();
    _ingredientsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _submitRecipe() async {
    final instructions = _instructionsController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final prepTime = _prepTimeController.text.trim();
    final cookTime = _cookTimeController.text.trim();
    final calories = _caloriesController.text.trim();

    if (instructions.isEmpty ||
        ingredients.isEmpty ||
        prepTime.isEmpty ||
        cookTime.isEmpty ||
        calories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // parse numeric values
    final parsedPrep = int.tryParse(prepTime) ?? 0;
    final parsedCook = int.tryParse(cookTime) ?? 0;
    final parsedCalories = int.tryParse(calories) ?? 0;

    // split lines or commas into list items, trimming empty space
    List<String> _splitToList(String input) {
      return input
          .split(RegExp(r'\r?\n|,'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final ingredientsList = _splitToList(ingredients);
    final instructionsList = _splitToList(instructions);

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    // if you are updating an existing recipe, call updateRecipe with a recipe created from the existing recipe
    if (widget.recipeToEdit != null) {
      final existing = widget.recipeToEdit!;
      final updatedRecipe = Recipe(
        id: existing.id,
        title: existing.title,
        ingredients: ingredientsList,
        instructions: instructionsList,
        prepTime: parsedPrep,
        cookTime: parsedCook,
        servings: existing.servings,
        calPerServing: parsedCalories,
        cuisine: existing.cuisine,
        dietRestrictions: existing.dietRestrictions,
        mealTypes: existing.mealTypes,
      );

      final success = await recipeProvider.updateRecipe(updatedRecipe);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar (
          const SnackBar(content: Text('Recipe updated. ')),
        );
        Navigator.of(context).pop(); // close the edit screen
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update recipe. ')),
        );
      }
      return;
    }

    // supabase section
    debugPrint('recipe added');
    debugPrint('Instructions: $instructions');
    debugPrint('Ingredients: $ingredients');
    debugPrint('Prep time: $prepTime');
    debugPrint('Cook time: $cookTime');
    debugPrint('Calories: $calories');
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final response = await Supabase.instance.client
          .from('recipes')
          .insert({
            'user_uuid': user.id,
            'name': '[placeholder recipe name]',
            'instructions': instructions,
            'ingredients': ingredients,
            'pre-time-min': int.parse(prepTime),
            'cook-time-min': int.parse(cookTime),
            'cal_per_serv': int.parse(calories),
          })
          .select(); // opcional: devuelve la fila insertada

      // clean fields
      _instructionsController.clear();
      _ingredientsController.clear();
      _prepTimeController.clear();
      _cookTimeController.clear();
      _caloriesController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding recipe: $e')),
      );
    }
  }
// UI Section - add recipe
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipeToEdit != null;
    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'Add your Personalized Recipe'),
        backgroundColor: const Color(0xFF839788),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_instructionsController, 'Instructions', maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_ingredientsController, 'Ingredients', maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_prepTimeController, 'Prep. Time (min)'),
            const SizedBox(height: 16),
            _buildTextField(_cookTimeController, 'Cook Time (min)'),
            const SizedBox(height: 16),
            _buildTextField(_caloriesController, 'Calories (kcal)'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitRecipe,
              icon: Icon(isEditing ? Icons.save : Icons.check),
              label: Text(isEditing ? 'Update recipe' : 'Add recipe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF839788),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
// function to build quicker the textfields
  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
