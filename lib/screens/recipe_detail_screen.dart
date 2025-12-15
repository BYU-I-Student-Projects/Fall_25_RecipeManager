// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

import '../widgets/star_rating_picker.dart';

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
  // =====================================================
  // ===== NEW: rating state ==============================
  // =====================================================
  int _myRating = 0; // 0 means "not rated yet"
  double _avgRating = 0.0;
  int _ratingCount = 0;
  bool _isLoadingRatings = true;
  // ===== END NEW =======================================
  // =====================================================

  @override
  void initState() {
    super.initState();
    // Initialize controller early
    _notesController = TextEditingController();

    // Start fetching the recipe and notes right away (existing logic)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipeById(widget.recipeId);
      final provider = Provider.of<RecipeProvider>(context, listen: false);

      // Existing: load recipe details
      await provider.fetchRecipeById(widget.recipeId);

      // ===== NEW: load ratings after recipe loads =====
      await _loadRatings();
      // ===== END NEW =====
    });
  }

  // =====================================================
  // ===== NEW: load rating info from provider ============
  // =====================================================
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
      // If something goes wrong, don't crash the UI
      if (!mounted) return;
      setState(() {
        _isLoadingRatings = false;
      });
      debugPrint('Error loading ratings: $e');
    }
  }
  // ===== END NEW =======================================
  // =====================================================

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
        color: bgColor.withValues(alpha: 127), // approx 0.5 opacity
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
        selection: TextSelection.collapsed(
            offset: recipeProvider.recipeNotes.length),
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
              textAlignVertical:
                  TextAlignVertical.top, // Start text at the top
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
                      : SingleChildScrollView(
                          child: DefaultTextStyle(
                            style: const TextStyle(
                                color: textColor, fontSize: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // =====================================================
                                // ===== NEW: Ratings UI block =========================
                                // =====================================================
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: accent1.withValues(alpha: 0.15),
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
                                                // Update UI immediately
                                                setState(() => _myRating = val);

                                                // Save to Supabase via provider
                                                try {
                                                  await recipeProvider
                                                      .setRecipeRating(
                                                    recipeId: widget.recipeId,
                                                    rating: val,
                                                  );
                                                  await _loadRatings(); // refresh avg + count
                                                } catch (e) {
                                                  debugPrint(
                                                      'Error saving rating: $e');
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Could not save rating.')),
                                                  );
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
                                // ===== END NEW =======================================
                                // =====================================================

                                Text(
                                  recipe.description!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: textColor,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Cuisine: ${recipe.cuisine}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                          'Diet: ${recipe.dietRestrictions}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
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
                                                fontWeight: FontWeight.bold)),
                                        Expanded(
                                            child: Text(ingredient.trim())),
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
                                    .map((entry) {
                                  final index = entry.key + 1;
                                  final step = entry.value.trim();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('$index. ',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Expanded(
                                            child: Text(step,
                                                style: const TextStyle(
                                                    height: 1.4))),
                                      ],
                                    ),
                                  );
                                }),

                                const SizedBox(height: 30),
                                const Divider(),

                                // --- Notes Section ---
                                // We wrap _buildNotesPanel in a SizedBox because it
                                // contains an Expanded widget. Inside a ScrollView,
                                // we must provide a finite height.
                                SizedBox(
                                  height: 300,
                                  child: _buildNotesPanel(context),
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