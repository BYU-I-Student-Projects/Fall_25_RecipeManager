// lib/screens/edit_recipe_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import 'recipe_form.dart';

class EditRecipeDialog extends StatelessWidget {
  final Recipe recipe;

  const EditRecipeDialog({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Recipe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF839788)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            
            // Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                child: RecipeForm(
                  initialRecipe: recipe,
                  submitButtonText: 'Save Changes',
                  onSubmit: (updatedRecipe) async {
                    final success = await Provider.of<RecipeProvider>(context, listen: false)
                        .updateRecipe(updatedRecipe);
                    
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recipe updated successfully!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update.')),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}