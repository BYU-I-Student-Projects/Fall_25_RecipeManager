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
  bool _isInitialized = false;

  // Rating state
  int _myRating = 0;
  double _avgRating = 0.0;
  int _ratingCount = 0;
  bool _isLoadingRatings = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipeById(widget.recipeId);
      final provider = Provider.of<RecipeProvider>(context, listen: false);

      await provider.fetchRecipeById(widget.recipeId);
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

  // --- Helper Widget Function (Only defined ONCE now) ---
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

  Widget _buildNotesPanel(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipe = recipeProvider.selectedRecipe;

    if (recipe == null) {
      return const Center(child: Text("No recipe loaded."));
    }

    if (_notesController.text != recipeProvider.recipeNotes) {
      _notesController.value = _notesController.value.copyWith(
        text: recipeProvider.recipeNotes,
        selection: TextSelection.collapsed(
            offset: recipeProvider.recipeNotes.length),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Recipe Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Add your cooking notes, substitutions, or tips here...',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Save logic here
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
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
                                Text(
                                  recipe.description!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Ingredients',
                                      // FIXED: Removed 'const' here
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