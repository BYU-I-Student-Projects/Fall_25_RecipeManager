// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/grocery_helper.dart';
import '../widgets/star_rating_picker.dart';

class RecipeDetailDialog extends StatefulWidget {
  final int recipeId;
  const RecipeDetailDialog({super.key, required this.recipeId});

  @override
  State<RecipeDetailDialog> createState() => _RecipeDetailDialogState();
}

class _RecipeDetailDialogState extends State<RecipeDetailDialog> {
  late TextEditingController _notesController;

  // Rating state
  int _myRating = 0;
  double _avgRating = 0.0;
  int _ratingCount = 0;
  bool _isLoadingRatings = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();

    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<RecipeProvider>(context, listen: false);

      // Fetch the recipe details (this also fetches the notes internally)
      await provider.fetchRecipeById(widget.recipeId);

      // Populate the notes controller with the fetched notes
      if (mounted) {
        _notesController.text = provider.recipeNotes;
      }

      // Load the ratings
      await _loadRatings();
    });
  }

  Future<void> _loadRatings() async {
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    try {
      final my = await provider.getMyRating(widget.recipeId);
      final summary = await provider.getRatingSummary(widget.recipeId);

      if (!mounted) return;
      setState(() {
        _myRating = my ?? 0;
        _avgRating = (summary['avg'] as num).toDouble();
        _ratingCount = summary['count'] as int;
        _isLoadingRatings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRatings = false;
      });
      debugPrint('Error loading ratings: $e');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // --- Helper Widget Function ---
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

  // --- Restored Notes Section ---
  Widget _buildNotesSection(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final theme = Theme.of(context);
    final headingColor = theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'My Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 8),
        recipeProvider.isLoadingNotes
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add your private notes, tips, or modifications here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await recipeProvider.saveNotes(
                          widget.recipeId, _notesController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note saved!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headingColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipe = recipeProvider.selectedRecipe;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            // Header
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

            // Content
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
                                // Ratings Block
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: accent1.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _isLoadingRatings
                                      ? const Row(
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                            SizedBox(width: 10),
                                            Text('Loading ratings...'),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Your rating',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            StarRatingPicker(
                                              value: _myRating,
                                              onChanged: (val) async {
                                                setState(() => _myRating = val);
                                                try {
                                                  await recipeProvider
                                                      .setRecipeRating(
                                                    recipeId: widget.recipeId,
                                                    rating: val,
                                                  );
                                                  await _loadRatings();
                                                } catch (e) {
                                                  debugPrint(
                                                      'Error saving rating: $e');
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              _ratingCount == 0
                                                  ? 'No ratings yet'
                                                  : 'Average: ${_avgRating.toStringAsFixed(1)} ($_ratingCount ratings)',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                ),
                                const SizedBox(height: 20),

                                // Description
                                Text(
                                  recipe.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Info Chips
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _infoChip(
                                        Icons.schedule,
                                        '${recipe.prepTime} min prep',
                                        accent2,
                                        isDark),
                                    _infoChip(
                                        Icons.soup_kitchen,
                                        '${recipe.cookTime} min cook',
                                        accent2,
                                        isDark),
                                    _infoChip(
                                        Icons.restaurant,
                                        '${recipe.servings} srv',
                                        accent2,
                                        isDark),
                                    _infoChip(
                                        Icons.local_fire_department,
                                        '${recipe.calPerServing} cal',
                                        accent2,
                                        isDark),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Cuisine & Diet
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: accent1.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cuisine: ${recipe.cuisine}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                                      Text(
                                        'Diet: ${recipe.dietRestrictions}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Ingredients
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Ingredients',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: headingColor,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        GroceryHelper.showAddIngredientsDialog(
                                          context,
                                          recipe,
                                        );
                                      },
                                      icon: const Icon(Icons.add_shopping_cart,
                                          size: 18),
                                      label: const Text('Add to List'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: headingColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
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
                                        Text(
                                          '• ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textColor),
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

                                // Instructions
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
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$index. ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: textColor),
                                          ),
                                          Expanded(
                                            child: Text(
                                              step,
                                              style: TextStyle(
                                                  height: 1.4,
                                                  color: textColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                // --- Notes Section Added Here ---
                                _buildNotesSection(context),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}