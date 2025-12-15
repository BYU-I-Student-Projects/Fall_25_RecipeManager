// lib/screens/add_recipe.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_form.dart'; // Import the new widget

class AddRecipeScreen extends StatelessWidget {
  final Recipe? recipeToEdit;

  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  Widget build(BuildContext context) {
    final isEditing = recipeToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'Add New Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: RecipeForm(
          initialRecipe: recipeToEdit,
          submitButtonText: isEditing ? 'Save Changes' : 'Add Recipe',
          onSubmit: (Recipe recipe) async {
            // Handle logic here (Provider calls, snackbars, navigation)
            final provider = Provider.of<RecipeProvider>(context, listen: false);
            bool success;

            if (isEditing) {
              success = await provider.updateRecipe(recipe);
            } else {
              success = await provider.addRecipe(recipe);
            }

            if (context.mounted) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Updated!' : 'Added!')),
                );
                // Safe pop check
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error saving recipe.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}