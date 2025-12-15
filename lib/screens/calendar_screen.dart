// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:recipe_manager/providers/theme_provider.dart';
import 'package:intl/intl.dart'; 

import '../providers/calendar_provider.dart';
import '../models/calendar_model.dart';
import '../models/recipe_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late List<String?> _selectedCategories;
  late List<Recipe?> _selectedRecipes;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mealProvider = context.read<MealDayProvider>();
      mealProvider.fetchMeals();
      mealProvider.fetchCalendarRecipes();
    });
  }

  List<MealDay> _getMealsForDay(DateTime date) {
    final mealProvider = context.read<MealDayProvider>();
    return mealProvider.meals.where((meal) {
      if (meal.eatDate == null) return false;
      return isSameDay(meal.eatDate, date);
    }).toList();
  }

  void _initializeDialogState(DateTime date) {
    final existingMeals = _getMealsForDay(date);
    final allRecipes = context.read<MealDayProvider>().recipes;

    _selectedCategories = List<String?>.filled(5, null);
    _selectedRecipes = List<Recipe?>.filled(5, null);

    for (int i = 0; i < existingMeals.length && i < 5; i++) {
      final meal = existingMeals[i];
      _selectedCategories[i] = meal.mealCategory;
      
      try {
        final matchingRecipe = allRecipes.firstWhere(
          (r) => r.title == meal.ingredients, 
        );
        _selectedRecipes[i] = matchingRecipe;
      } catch (e) {
        _selectedRecipes[i] = null;
      }
    }
  }

  Future<void> _onSaveAllMeals(DateTime date) async {
    final provider = context.read<MealDayProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final existingMeals = _getMealsForDay(date);
    for (var meal in existingMeals) {
      await provider.deleteMeal(meal.idMeal);
    }

    int mealsSavedCount = 0;
    for (var i = 0; i < _selectedCategories.length; i++) {
      final cat = _selectedCategories[i];
      final rec = _selectedRecipes[i];

      if (cat != null && rec != null) {
        final newMeal = MealDay(
          idMeal: '',
          createdAt: DateTime.now(),
          userId: '', 
          mealCategory: cat,
          ingredients: rec.title, 
          eatDate: date,
        );
        await provider.addMeal(newMeal);
        mealsSavedCount++;
      }
    }

    if (navigator.mounted) navigator.pop(); 
    
    if (scaffoldMessenger.mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Saved $mealsSavedCount meals for ${DateFormat.MMMd().format(date)}'),
          backgroundColor: const Color(0xFF839788),
        ),
      );
    }
  }

  Future<void> _clearDay(DateTime date) async {
    final provider = context.read<MealDayProvider>();
    final navigator = Navigator.of(context);
    
    final existingMeals = _getMealsForDay(date);
    for (var meal in existingMeals) {
      await provider.deleteMeal(meal.idMeal);
    }

    if (navigator.mounted) navigator.pop(); 
  }

  void _showAddMealDialog(DateTime date) {
    _initializeDialogState(date);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter dialogSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor, 
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Meals',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat.yMMMMEEEEd().format(date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Consumer<MealDayProvider>(
                      builder: (context, mealProvider, _) {
                        if (mealProvider.isLoadingRecipes) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }

                        final categories = mealProvider.availableMealTypes;

                        return Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return _buildMealRow(
                                  rowIndex: index,
                                  categories: categories,
                                  mealProvider: mealProvider,
                                  dialogSetState: dialogSetState,
                                  isDark: isDark,
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => _clearDay(date),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Clear Day', style: TextStyle(color: Colors.red)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _onSaveAllMeals(date),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF839788),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealRow({
    required int rowIndex,
    required List<String> categories,
    required MealDayProvider mealProvider,
    required StateSetter dialogSetState,
    required bool isDark,
  }) {
    final String? selectedCategory = _selectedCategories[rowIndex];
    final Recipe? selectedRecipe = _selectedRecipes[rowIndex];

    // CHANGED: Use all recipes instead of filtering by category
    final List<Recipe> allRecipes = mealProvider.recipes;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 20, 
            child: Text(
              '${rowIndex + 1}.', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white70 : Colors.black54
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text('Type', style: TextStyle(fontSize: 13)),
              isExpanded: true,
              menuMaxHeight: 300,
              decoration: _inputDecoration(isDark),
              items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (value) {
                dialogSetState(() {
                  _selectedCategories[rowIndex] = value;
                  // CHANGED: Do NOT reset the recipe when category changes
                });
              },
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            flex: 3,
            child: DropdownButtonFormField<Recipe>(
              // Ensure the selected recipe exists in the full list, otherwise null
              value: allRecipes.contains(selectedRecipe) ? selectedRecipe : null,
              hint: const Text('Recipe', style: TextStyle(fontSize: 13)),
              isExpanded: true,
              menuMaxHeight: 300,
              decoration: _inputDecoration(isDark),
              // CHANGED: Map allRecipes instead of filtered recipes
              items: allRecipes.map((r) => DropdownMenuItem(value: r, child: Text(r.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (value) {
                dialogSetState(() {
                  _selectedRecipes[rowIndex] = value;
                });
              },
            ),
          ),

          if (selectedCategory != null || selectedRecipe != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                dialogSetState(() {
                  _selectedCategories[rowIndex] = null;
                  _selectedRecipes[rowIndex] = null;
                });
              },
            )
          else 
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildMealListForDay(DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<MealDayProvider>(
      builder: (context, provider, _) {
        final meals = _getMealsForDay(date);
        
        if (meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 48, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No meals planned for ${DateFormat.E().format(date)}',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isDark ? BorderSide(color: Colors.grey[700]!) : BorderSide.none,
              ),
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF839788).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.dining, color: Color(0xFF839788)),
                ),
                title: Text(
                  meal.ingredients ?? 'Unknown Recipe', 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  meal.mealCategory ?? 'Meal',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: bgColor,
          child: Column(
            children: [
               
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    if (_selectedDay != null && isSameDay(_selectedDay, selectedDay)) {
                       _showAddMealDialog(selectedDay);
                    } else {
                       _selectedDay = selectedDay;
                    }
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Color(0xFF839788),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFFBAA898),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
                  weekendTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  outsideTextStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
                ),
              ),
              
              const Divider(height: 20, thickness: 1),

              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        DateFormat.MMMMEEEEd().format(_selectedDay!),
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              Expanded(
                child: _selectedDay == null 
                  ? Center(child: Text('Select a day to view meals', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)))
                  : _buildMealListForDay(_selectedDay!),
              ),

              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddMealDialog(_selectedDay!),
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text('Modify Meals'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF839788),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}