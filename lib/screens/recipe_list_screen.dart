// lib/screens/recipe_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_list_item.dart';
import '../models/recipe_model.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // A threshold helps trigger the fetch before the user hits the absolute bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<RecipeProvider>(context, listen: false).fetchMoreRecipes();
    }
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    List<Recipe> filtered = recipes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final recipeTitle = recipe.title.toLowerCase();
        final recipeCuisine = recipe.cuisine.toLowerCase();
        final recipeIngredients = recipe.ingredients.join(' ').toLowerCase();
        
        final query = _searchQuery.toLowerCase();
        
        // Search in title, cuisine, and ingredients
        return recipeTitle.contains(query) || 
               recipeCuisine.contains(query) ||
               recipeIngredients.contains(query);
      }).toList();
    }

    // Apply filter based on cuisine or diet restrictions
    if (_selectedFilter != 'All') {
      filtered = filtered.where((recipe) {
        // Check if the filter matches cuisine or diet restrictions
        return recipe.cuisine.toLowerCase() == _selectedFilter.toLowerCase() ||
               recipe.dietRestrictions.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _showFilterMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'All',
          child: Text('All Recipes'),
        ),
        const PopupMenuDivider(),
        // Cuisine filters
        const PopupMenuItem<String>(
          value: 'American',
          child: Text('American'),
        ),
        const PopupMenuItem<String>(
          value: 'Chinese',
          child: Text('Chinese'),
        ),
        const PopupMenuItem<String>(
          value: 'French',
          child: Text('French'),
        ),
        const PopupMenuItem<String>(
          value: 'Italian',
          child: Text('Italian'),
        ),
        const PopupMenuItem<String>(
          value: 'Indian',
          child: Text('Indian'),
        ),
        const PopupMenuItem<String>(
          value: 'Greek',
          child: Text('Greek'),
        ),
        const PopupMenuItem<String>(
          value: 'Mexican',
          child: Text('Mexican'),
        ),
        const PopupMenuItem<String>(
          value: 'Thai',
          child: Text('Thai'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedFilter = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final filteredRecipes = _filterRecipes(recipeProvider.recipes);

    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF839788),
        title: const Text('My Recipes'),
      ),
      body: SafeArea(
<<<<<<< Updated upstream
        child: recipeProvider.isLoading
=======
        child: recipeProvider.isLoading && recipeProvider.recipes.isEmpty
>>>>>>> Stashed changes
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search Icon/Bar and Filter Icon
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: _isSearching
                          ? TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search recipes...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggleSearch,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Search Icon
                                IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    size: 28,
                                    color: Color(0xFF839788),
                                  ),
                                  onPressed: _toggleSearch,
                                ),
                                const SizedBox(width: 8),
                                // Filter Icon
                                Builder(
                                  builder: (context) => Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.filter_list,
                                          size: 28,
                                          color: Color(0xFF839788),
                                        ),
                                        onPressed: () => _showFilterMenu(context),
                                      ),
                                      if (_selectedFilter != 'All')
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  // Active Filter Chip
                  if (_selectedFilter != 'All')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Chip(
                            label: Text(_selectedFilter),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                            },
                            backgroundColor: const Color(0xFF839788),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  // Recipe List
                  Expanded(
                    child: filteredRecipes.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty && _selectedFilter == 'All'
                                  ? 'No recipes yet'
                                  : 'No recipes found',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredRecipes.length + (recipeProvider.hasMore ? 1 : 0),
                            itemBuilder: ((context, index) {
                              // Check if we are at the end of the list
                              if (index == filteredRecipes.length) {
                                // Only show the bottom indicator if we're loading more
                                return recipeProvider.isLoadingMore
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              final Recipe recipe = filteredRecipes[index];
                              return RecipeListItem(recipe: recipe);
                            }),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}