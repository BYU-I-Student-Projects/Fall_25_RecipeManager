// lib/screens/add_recipe_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_form.dart'; 

class AddRecipeScreen extends StatelessWidget {
  final Recipe? recipeToEdit;

  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  Widget build(BuildContext context) {
    final isEditing = recipeToEdit != null;
    final theme = Theme.of(context);
    final canPop = Navigator.canPop(context);

    return Scaffold(
      // Removed AppBar
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    // Only show back button if we can go back (i.e. we are editing)
                    if (canPop) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isEditing ? 'Edit Recipe' : 'Add New Recipe',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              RecipeForm(
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
            ],
          ),
        ),
      ),
    );
  }
}