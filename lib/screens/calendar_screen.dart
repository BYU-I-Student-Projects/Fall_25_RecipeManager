// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
// ... (rest of imports remain the same)
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:recipe_manager/providers/theme_provider.dart';

import '../providers/calendar_provider.dart';
import '../models/calendar_model.dart';
import '../models/recipe_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // ... (Keep existing variables and methods: initState, _onAddMeal, _onSaveAllMeals)
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String?> _selectedCategories = List<String?>.filled(5, null);
  final List<Recipe?> _selectedRecipes = List<Recipe?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mealProvider = context.read<MealDayProvider>();
      mealProvider.fetchMeals();
      mealProvider.fetchCalendarRecipes();
    });
  }

  Future<bool> _onAddMeal({required String mealCategory, required Recipe selectedRecipe}) async {
      if (_selectedDay == null) return false;
      final provider = context.read<MealDayProvider>();
      final meal = MealDay(
        idMeal: '', 
        createdAt: DateTime.now(),
        userId: '', 
        mealCategory: mealCategory,
        ingredients: selectedRecipe.title,
        eatDate: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day),
      );
      return await provider.addMeal(meal);
  }

  Future<void> _onSaveAllMeals() async {
    // ... (Keep existing implementation)
    if (_selectedDay == null) return;
    final localContext = context;
    int mealsSavedCount = 0;
    for (var i = 0; i < _selectedCategories.length; i++) {
      final selectedCategory = _selectedCategories[i];
      final selectedRecipe = _selectedRecipes[i];
      if (selectedCategory != null && selectedRecipe != null) {
        final success = await _onAddMeal(
          mealCategory: selectedCategory,
          selectedRecipe: selectedRecipe,
        );
        if (success) mealsSavedCount++;
      }
    }
    if (localContext.mounted) Navigator.pop(localContext);
    if (localContext.mounted) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(content: Text(mealsSavedCount > 0 ? '$mealsSavedCount meal(s) saved.' : 'No selected meals.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      // Removed AppBar
      body: SafeArea(
        child: Container(
          color: const Color(0xFFEEE0CB),
          child: Column(
            children: [
               // Custom Header
               Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
               ),
              TableCalendar(
                // ... (Keep existing TableCalendar configuration)
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  // ... (Keep existing selection logic)
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                      _focusedDay = focusedDay;
                      for (var i = 0; i < _selectedCategories.length; i++) {
                        _selectedCategories[i] = null;
                        _selectedRecipes[i] = null;
                      }
                    });
                    
                    // ... (Keep existing popup logic)
                    Future.delayed(const Duration(milliseconds: 300), () {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) {
                            // ... (Keep existing dialog builder)
                             return StatefulBuilder(
                                builder: (BuildContext dialogContext, StateSetter dialogSetState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(color: const Color(0xFFEEE0CB), borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Your meals for today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Text('${selectedDay.day}/${selectedDay.month}/${selectedDay.year}', style: const TextStyle(fontSize: 16)),
                                          const SizedBox(height: 12),
                                          // Dropdowns
                                          Consumer<MealDayProvider>(
                                            builder: (context, mealProvider, _) {
                                               if (mealProvider.isLoadingRecipes && mealProvider.recipes.isEmpty) return const CircularProgressIndicator();
                                               final categories = mealProvider.availableMealTypes;
                                               return Column(
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: List.generate(5, (index) {
                                                   return Padding(padding: const EdgeInsets.only(bottom: 12),
                                                     child: _buildMealRow(rowIndex: index, categories: categories, mealProvider: mealProvider, dialogSetState: dialogSetState),
                                                   );
                                                 }),
                                               );
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: _onSaveAllMeals,
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF839788)),
                                                child: const Text('Save Meals'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                             );
                          },
                        );
                    });
                  }
                },
                onFormatChanged: (format) { if (_calendarFormat != format) setState(() => _calendarFormat = format); },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                calendarStyle: CalendarStyle(
                   todayDecoration: const BoxDecoration(color: Color(0xFF839788), shape: BoxShape.circle),
                   selectedDecoration: const BoxDecoration(color: Color(0xFFBAA898), shape: BoxShape.circle),
                   defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
                   weekendTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                   outsideTextStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  weekendStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      child: Text('${day.day}', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    );
                  },
                ),
              ),
              // ...
              const SizedBox(height: 8.0),
              Expanded(
                child: Center(
                  child: _selectedDay != null
                      ? Text(
                          'Selected day: ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      : Text(
                          'No day selected',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ... (Keep _buildMealRow method)
  Widget _buildMealRow({required int rowIndex, required List<String> categories, required MealDayProvider mealProvider, required StateSetter dialogSetState}) {
    // ... (Keep existing implementation)
    final String? selectedCategory = _selectedCategories[rowIndex];
    final Recipe? selectedRecipe = _selectedRecipes[rowIndex];
    final List<Recipe> recipesForCategory = selectedCategory == null ? <Recipe>[] : mealProvider.recipesForMealType(selectedCategory);

    return Row(
      children: [
        Expanded(flex: 1, child: DropdownButtonFormField<String>(
            initialValue: selectedCategory, hint: const Text('Category'), isExpanded: true,
            decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            items: categories.map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat))).toList(),
            onChanged: (value) { dialogSetState(() { _selectedCategories[rowIndex] = value; _selectedRecipes[rowIndex] = null; }); },
        )),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: DropdownButtonFormField<Recipe>(
            initialValue: recipesForCategory.contains(selectedRecipe) ? selectedRecipe : null, hint: const Text('Meal'), isExpanded: true,
            decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            items: recipesForCategory.map((recipe) => DropdownMenuItem<Recipe>(value: recipe, child: Text(recipe.title))).toList(),
            onChanged: (recipe) { dialogSetState(() { _selectedRecipes[rowIndex] = recipe; }); },
        )),
      ],
    );
  }
}