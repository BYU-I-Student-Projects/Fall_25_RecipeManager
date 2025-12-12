// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailDialog extends StatefulWidget {
  final int recipeId;
  const RecipeDetailDialog({super.key, required this.recipeId});

  @override
  State<RecipeDetailDialog> createState() => _RecipeDetailDialogState();
}

class _RecipeDetailDialogState extends State<RecipeDetailDialog> {
  // Use a local controller to manage the TextField state.
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // Fetch recipe details when the dialog is first shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipeById(widget.recipeId);
    });

    // Initialize the controller here.
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // --- Helper Widget Functions ---

  Widget _infoChip(IconData icon, String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 127),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildNotesPanel(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipe = recipeProvider.selectedRecipe;

    if (recipe == null) {
      return const Center(child: Text("No recipe loaded."));
    }

    // Update the controller text when the provider's notes change
    if (_notesController.text != recipeProvider.recipeNotes) {
      _notesController.text = recipeProvider.recipeNotes;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF839788),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _notesController,
            maxLines: null,
            expands: true,
            // FIX: Add textAlignVertical to force content to the top
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: "Write your notes here...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              recipeProvider.saveNotes(recipe.id!, _notesController.text);
            },
            child: const Text("Save Note"),
          ),
        ),
      ],
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipe = recipeProvider.selectedRecipe;

    // --- Palette ---
    const textColor = Color(0xFF000000);
    const headingColor = Color(0xFF839788);
    const backgroundColor = Color(0xFFEEE0CB); // Background for the dialog
    const accent1 = Color(0xFFBAA898);
    const accent2 = Color(0xFFBFD7EA);

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16), // Spacing from screen edges
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrink to fit content height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header (Title + Close Button) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recipe?.title ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 24, // Slightly smaller than full screen
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 24, color: headingColor),

            // --- Scrollable Body ---
            Expanded(
              child: recipeProvider.isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : recipe == null
                      ? const Center(child: Text('Recipe not found.'))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT — recipe details
                            Expanded(
                              flex: 2,
                              child: SingleChildScrollView(
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                      color: textColor, fontSize: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // --- Quick Info ---
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _infoChip(
                                              Icons.schedule,
                                              '${recipe.prepTime} min prep',
                                              accent2),
                                          _infoChip(
                                              Icons.soup_kitchen,
                                              '${recipe.cookTime} min cook',
                                              accent2),
                                          _infoChip(
                                              Icons.restaurant,
                                              '${recipe.servings} srv',
                                              accent2),
                                          _infoChip(
                                              Icons.local_fire_department,
                                              '${recipe.calPerServing} cal',
                                              accent2),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Cuisine + Diet ---
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 12),
                                        decoration: BoxDecoration(
                                          // FIX: Replace .withOpacity(0.2) with .withValues(alpha: 51)
                                          color: accent1.withValues(alpha: 51),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Cuisine: ${recipe.cuisine}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                                'Diet: ${recipe.dietRestrictions}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Ingredients ---
                                      Text(
                                        'Ingredients',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: headingColor),
                                      ),
                                      const SizedBox(height: 8),
                                      ...recipe.ingredients.map(
                                        (ingredient) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('• ',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Expanded(
                                                  child:
                                                      Text(ingredient.trim())),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // --- Instructions ---
                                      Text(
                                        'Instructions',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: headingColor),
                                      ),
                                      const SizedBox(height: 8),
                                      ...recipe.instructions
                                          .asMap()
                                          .entries
                                          .map(
                                        (entry) {
                                          final index = entry.key + 1;
                                          final step = entry.value.trim();
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('$index. ',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Expanded(
                                                    child: Text(step,
                                                        style: const TextStyle(
                                                            height: 1.4))),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // RIGHT — Notes
                            Expanded(
                              flex: 1,
                              child: _buildNotesPanel(context),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
