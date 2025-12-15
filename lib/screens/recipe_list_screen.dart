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
  String _selectedCuisineFilter = 'All';
  String _selectedMealTypeFilter = 'All';
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Schedule the fetch to happen after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // === Added Missing Method ===
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      Provider.of<RecipeProvider>(context, listen: false).fetchMoreRecipes();
    }
  }
  // ============================

  // Client-side filter for search only
  List<Recipe> _filterRecipesBySearch(List<Recipe> recipes) {
    if (_searchQuery.isEmpty) {
      return recipes;
    }

    return recipes.where((recipe) {
      final recipeTitle = recipe.title.toLowerCase();
      final recipeCuisine = recipe.cuisine.toLowerCase();
      final recipeIngredients = recipe.ingredients.join(' ').toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return recipeTitle.contains(query) || 
             recipeCuisine.contains(query) ||
             recipeIngredients.contains(query);
    }).toList();
  }

  void _applyFilters() {
    final cuisineFilter = _selectedCuisineFilter == 'All' ? null : _selectedCuisineFilter;
    final mealTypeFilter = _selectedMealTypeFilter == 'All' ? null : _selectedMealTypeFilter;
    
    Provider.of<RecipeProvider>(context, listen: false)
        .fetchRecipes(cuisineFilter: cuisineFilter, mealTypeFilter: mealTypeFilter);
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

  void _showCuisineFilterMenu(BuildContext context) {
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
          child: Text('All Cuisines'),
        ),
        const PopupMenuDivider(),
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
          _selectedCuisineFilter = value;
        });
        _applyFilters();
      }
    });
  }

  void _showMealTypeFilterMenu(BuildContext context) {
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
          child: Text('All Meal Types'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'Breakfast',
          child: Text('Breakfast'),
        ),
        const PopupMenuItem<String>(
          value: 'Brunch',
          child: Text('Brunch'),
        ),
        const PopupMenuItem<String>(
          value: 'Lunch',
          child: Text('Lunch'),
        ),
        const PopupMenuItem<String>(
          value: 'Dinner',
          child: Text('Dinner'),
        ),
        const PopupMenuItem<String>(
          value: 'Snack',
          child: Text('Snack'),
        ),
        const PopupMenuItem<String>(
          value: 'Dessert',
          child: Text('Dessert'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedMealTypeFilter = value;
        });
        _applyFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final filteredRecipes = _filterRecipesBySearch(recipeProvider.recipes);

    return Scaffold(
      backgroundColor: const Color(0xFFEEE0CB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF839788),
        title: const Text('My Recipes'),
      ),
      body: SafeArea(
        child: recipeProvider.isLoading && recipeProvider.recipes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search Bar and Filter Icons
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
                                // Meal Type Filter Icon
                                Builder(
                                  builder: (context) => Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.restaurant_menu,
                                          size: 28,
                                          color: Color(0xFF839788),
                                        ),
                                        onPressed: () => _showMealTypeFilterMenu(context),
                                      ),
                                      if (_selectedMealTypeFilter != 'All')
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
                                const SizedBox(width: 8),
                                // Cuisine Filter Icon
                                Builder(
                                  builder: (context) => Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.filter_list,
                                          size: 28,
                                          color: Color(0xFF839788),
                                        ),
                                        onPressed: () => _showCuisineFilterMenu(context),
                                      ),
                                      if (_selectedCuisineFilter != 'All')
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
                  // Active Filter Chips
                  if (_selectedCuisineFilter != 'All' || _selectedMealTypeFilter != 'All')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          if (_selectedMealTypeFilter != 'All')
                            Chip(
                              label: Text(_selectedMealTypeFilter),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedMealTypeFilter = 'All';
                                });
                                _applyFilters();
                              },
                              backgroundColor: const Color(0xFF839788),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          if (_selectedCuisineFilter != 'All')
                            Chip(
                              label: Text(_selectedCuisineFilter),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedCuisineFilter = 'All';
                                });
                                _applyFilters();
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
                              _searchQuery.isEmpty && _selectedCuisineFilter == 'All' && _selectedMealTypeFilter == 'All'
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
                            itemCount: filteredRecipes.length + (recipeProvider.hasMore && _searchQuery.isEmpty ? 1 : 0),
                            itemBuilder: ((context, index) {
                              // Show loading indicator at the bottom only when not filtering/searching
                              if (index == filteredRecipes.length) {
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