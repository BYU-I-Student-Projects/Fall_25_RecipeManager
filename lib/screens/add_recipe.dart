import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    // Verificar si el usuario está logueado
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Si no hay usuario, redirigir al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
      });
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _ingredientsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  // submit recipe to Supabase
  void _submitRecipe() async {
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
            'user_id': user.id,
            'instructions': instructions,
            'ingredients': ingredients,
            'prep_time': int.parse(prepTime),
            'cook_time': int.parse(cookTime),
            'calories': int.parse(calories),
          })
          .select(); // opcional: devuelve la fila insertada

      // Limpiar campos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        title: const Text('Add your Personalized Recipe'),
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
              icon: const Icon(Icons.check),
              label: const Text('Add recipe'),
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
