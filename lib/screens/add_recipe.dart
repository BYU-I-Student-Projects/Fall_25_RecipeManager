import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

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
    //     required this.id,
    //required this.title,
    //required this.ingredients, 
    //required this.instructions,
    //required this.prepTime, 
    //required this.cookTime, 
    //required this.servings,
    //required this.calPerServing,
    //required this.cuisine,
    //required this.dietRestrictions,
    //required this.mealTypes, 
    final newRecipe = Recipe(
      // You'll need to add a Title field to your form
      title: 'New Recipe Title', // e.g., _titleController.text.trim()
      instructions: instructions.toString().split('\n'),
      ingredients: ingredients.toString().split('\n'),
      prepTime: int.parse(prepTime), // Add try-catch for int.parse
      cookTime: int.parse(cookTime),
      servings: 1, // Default value; you can add a field for this
      calPerServing: int.parse(calories),
      cuisine: 'Unknown', // Default value; you can add a field for this
      dietRestrictions: 'None', // Default value; you can add a field for this
      mealTypes: ['Other'], // Default value; you can add a field for this
    );

    final provider = Provider.of<RecipeProvider>(context, listen: false);
    final bool success = await provider.addRecipe(newRecipe);

    if (mounted) { // Good practice: check if widget is still visible
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe added successfully!')),
        );
        // Clear fields
        _instructionsController.clear();
        _ingredientsController.clear();
        _prepTimeController.clear();
        _cookTimeController.clear();
        _caloriesController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding recipe. Please try again.')),
        );
      }
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
