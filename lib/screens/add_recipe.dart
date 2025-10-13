import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

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

  void _submitRecipe() {
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
        const SnackBar(content: Text('Please fill the next text box')),
      );
      return;
    }

    // supabase section
    print('recipe added');
    print('Instructions: $instructions');
    print('Ingredients: $ingredients');
    print('Prep time: $prepTime');
    print('Cook time: $cookTime');
    print('Calories: $calories');

    // clean fields
    _instructionsController.clear();
    _ingredientsController.clear();
    _prepTimeController.clear();
    _cookTimeController.clear();
    _caloriesController.clear();

    // confirmation text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recepie Added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your Personalized Recipe'),
        backgroundColor: Colors.blueAccent,
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
            _buildTextField(_caloriesController, 'Caloríes (kcal)'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitRecipe,
              icon: const Icon(Icons.check),
              label: const Text('Add recipe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
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

  // Widget helper to not repeat code
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
