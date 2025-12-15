// lib/widgets/recipe_form.dart
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeForm extends StatefulWidget {
  final Recipe? initialRecipe;
  final String submitButtonText;
  final Future<void> Function(Recipe recipe) onSubmit;

  const RecipeForm({
    super.key,
    this.initialRecipe,
    required this.submitButtonText,
    required this.onSubmit,
  });

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _cuisineController;
  late TextEditingController _dietController;
  late TextEditingController _servingsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _caloriesController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecipe;
    
    _titleController = TextEditingController(text: r?.title ?? '');
    _cuisineController = TextEditingController(text: r?.cuisine ?? '');
    _dietController = TextEditingController(text: r?.dietRestrictions ?? '');
    _servingsController = TextEditingController(text: r?.servings.toString() ?? '');
    _prepTimeController = TextEditingController(text: r?.prepTime.toString() ?? '');
    _cookTimeController = TextEditingController(text: r?.cookTime.toString() ?? '');
    _caloriesController = TextEditingController(text: r?.calPerServing.toString() ?? '');
    _ingredientsController = TextEditingController(text: r?.ingredients.join('\n') ?? '');
    _instructionsController = TextEditingController(text: r?.instructions.join('\n') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cuisineController.dispose();
    _dietController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Parse inputs
    final int servings = int.tryParse(_servingsController.text.trim()) ?? 1;
    final int prepTime = int.tryParse(_prepTimeController.text.trim()) ?? 0;
    final int cookTime = int.tryParse(_cookTimeController.text.trim()) ?? 0;
    final int calories = int.tryParse(_caloriesController.text.trim()) ?? 0;

    final List<String> ingredientsList = _ingredientsController.text
        .trim()
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final List<String> instructionsList = _instructionsController.text
        .trim()
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.initialRecipe?.id, // Keep ID if editing
      title: _titleController.text.trim(),
      cuisine: _cuisineController.text.trim().isEmpty ? 'Unknown' : _cuisineController.text.trim(),
      dietRestrictions: _dietController.text.trim().isEmpty ? 'None' : _dietController.text.trim(),
      servings: servings,
      prepTime: prepTime,
      cookTime: cookTime,
      calPerServing: calories,
      ingredients: ingredientsList,
      instructions: instructionsList,
      mealTypes: widget.initialRecipe?.mealTypes ?? ['Other'],
    );

    widget.onSubmit(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(controller: _titleController, label: 'Recipe Title', isRequired: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(controller: _cuisineController, label: 'Cuisine')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(controller: _dietController, label: 'Diet')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(controller: _prepTimeController, label: 'Prep (min)', isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(controller: _cookTimeController, label: 'Cook (min)', isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(controller: _servingsController, label: 'Servings', isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(controller: _caloriesController, label: 'Calories', isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: _ingredientsController, label: 'Ingredients (one per line)', maxLines: 5, isRequired: true),
          const SizedBox(height: 16),
          _buildTextField(controller: _instructionsController, label: 'Instructions (one per line)', maxLines: 5, isRequired: true),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.save),
            label: Text(widget.submitButtonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isNumber = false,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (isNumber && value != null && value.trim().isNotEmpty) {
          if (int.tryParse(value.trim()) == null) {
            return 'Enter a valid number';
          }
        }
        return null;
      },
    );
  }
}