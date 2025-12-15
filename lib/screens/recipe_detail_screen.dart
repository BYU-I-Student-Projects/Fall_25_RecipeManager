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
// 1. Declare the controller and a flag for initialization
  late TextEditingController _notesController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller early
    _notesController = TextEditingController();

    // Start fetching the recipe and notes right away (existing logic)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipeById(widget.recipeId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final recipeProvider =
          Provider.of<RecipeProvider>(context, listen: false);

      _notesController.text = recipeProvider.recipeNotes;

      _isInitialized = true;
    }
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

    if (_notesController.text != recipeProvider.recipeNotes) {
      _notesController.value = _notesController.value.copyWith(
        text: recipeProvider.recipeNotes,
        selection:
            TextSelection.collapsed(offset: recipeProvider.recipeNotes.length),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // IMPORTANT: The column inside _buildNotesPanel needs to stretch
        // to fill the height provided by its parent Expanded widget.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Recipe Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 1. WRAP THE TEXT FIELD IN EXPANDED
          Expanded(
            child: TextField(
              controller: _notesController,
              // 2. SET maxLines TO NULL for dynamic sizing
              maxLines: null,
              // 3. SET expands TO TRUE so it fills the Expanded parent
              expands: true,
              textAlignVertical: TextAlignVertical.top, // Start text at the top
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Add your cooking notes, substitutions, or tips here...',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // The Save Button (will sit at the bottom)
          ElevatedButton(
            onPressed: () {
              // ... (saving logic)
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipe = recipeProvider.selectedRecipe;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors based on theme
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final headingColor = theme.primaryColor;
    final backgroundColor = theme.dialogBackgroundColor;
    final accent1 = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFBAA898);
    final accent2 = isDark ? const Color(0xFF4A5A6A) : const Color(0xFFBFD7EA);

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Divider(height: 24, color: headingColor),

            // --- Scrollable Body ---
            Expanded(
              child: recipeProvider.isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : recipe == null
                      ? Center(
                          child: Text(
                            'Recipe not found.',
                            style: TextStyle(color: textColor),
                          ),
                        )
                      : SingleChildScrollView(
                          child: DefaultTextStyle(
                            style: TextStyle(color: textColor, fontSize: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- Quick Info ---
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _infoChip(Icons.schedule, '${recipe.prepTime} min prep', accent2, isDark),
                                    _infoChip(Icons.soup_kitchen, '${recipe.cookTime} min cook', accent2, isDark),
                                    _infoChip(Icons.restaurant, '${recipe.servings} srv', accent2, isDark),
                                    _infoChip(Icons.local_fire_department, '${recipe.calPerServing} cal', accent2, isDark),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // --- Cuisine + Diet ---
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: accent1.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cuisine: ${recipe.cuisine}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'Diet: ${recipe.dietRestrictions}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
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
                                          // Corrected alpha value for ~0.2 opacity
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

                                // --- Ingredients ---
                                Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: headingColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...recipe.ingredients.map(
                                  (ingredient) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            ingredient.trim(),
                                            style: TextStyle(color: textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // --- Instructions ---
                                Text(
                                  'Instructions',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: headingColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...recipe.instructions.asMap().entries.map(
                                  (entry) {
                                    final index = entry.key + 1;
                                    final step = entry.value.trim();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$index. ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              step,
                                              style: TextStyle(
                                                height: 1.4,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
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

  Widget _infoChip(IconData icon, String text, Color bgColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
}
