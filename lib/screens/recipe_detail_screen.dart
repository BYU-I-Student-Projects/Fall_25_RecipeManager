// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipeById(widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipe = recipeProvider.selectedRecipe;

    // --- Palette ---
    const textColor = Color(0xFF000000);
    const headingColor = Color(0xFF839788);
    const backgroundColor = Color(0xFFEEE0CB);
    const accent1 = Color(0xFFBAA898);
    const accent2 = Color(0xFFBFD7EA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: headingColor,
        title: Text(
          recipe?.title ?? 'Loading...',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: recipeProvider.isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : recipe == null
              ? const Center(child: Text('Recipe not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: textColor, fontSize: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Title ---
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Quick Info ---
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _infoChip(Icons.schedule,
                                'Prep: ${recipe.prepTime} min', accent2),
                            _infoChip(Icons.soup_kitchen,
                                'Cook: ${recipe.cookTime} min', accent2),
                            _infoChip(Icons.restaurant,
                                '${recipe.servings} servings', accent2),
                            _infoChip(Icons.local_fire_department,
                                '${recipe.calPerServing} cal/serving', accent2),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Cuisine + Diet ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: accent1.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cuisine: ${recipe.cuisine}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text('Diet: ${recipe.dietRestrictions}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: accent1.withValues(alpha: 0.6)),

                        // --- Ingredients ---
                        Text(
                          'Ingredients',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...recipe.ingredients.map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(fontSize: 18)),
                                Expanded(child: Text(ingredient.trim())),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: accent1.withValues(alpha: 0.6)),

                        // --- Instructions ---
                        Text(
                          'Instructions',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...recipe.instructions.asMap().entries.map(
                          (entry) {
                            final index = entry.key + 1;
                            final step = entry.value.trim();
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '$index. $step',
                                style: const TextStyle(height: 1.5),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color bgColor) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.black87),
      label: Text(text, style: const TextStyle(color: Colors.black87)),
      backgroundColor: bgColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
