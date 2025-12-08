import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

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

  // Estado: categoría seleccionada y receta seleccionada para cada una de las 5 filas
  final List<String?> _selectedCategories = List<String?>.filled(5, null);
  final List<Recipe?> _selectedRecipes = List<Recipe?>.filled(5, null);

  @override
  void initState() {
    super.initState();

    // Cargar la data necesaria desde Supabase al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final mealProvider = context.read<MealDayProvider>();
      // Meals ya asignados a días específicos
      mealProvider.fetchMeals();
      // Recetas disponibles para elegir por tipo de meal
      mealProvider.fetchCalendarRecipes();
    });
  }

  // Maneja el guardado de una comida usando el provider y el modelo MealDay
  Future<bool> _onAddMeal({
    required String mealCategory,
    required Recipe selectedRecipe,
  }) async {
    if (_selectedDay == null) {
      debugPrint('Error: No day selected for meal saving.');
      return false;
    }

    final provider = context.read<MealDayProvider>();

    final meal = MealDay(
      idMeal: '', // Lo genera Supabase
      createdAt: DateTime.now(),
      userId: '', // Se sobreescribe en el provider con el usuario actual
      mealCategory: mealCategory,
      // Guardamos el nombre de la receta seleccionada para mostrarla luego
      ingredients: selectedRecipe.title,
      eatDate: DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      ),
    );

    // addMeal retorna true/false si tiene éxito o no
    return await provider.addMeal(meal);
  }

  // === FUNCIÓN: Guarda todas las comidas seleccionadas a la vez ===
  Future<void> _onSaveAllMeals() async {
    if (_selectedDay == null) return;

    // Usamos un BuildContext local para mostrar el SnackBar después de un await
    final localContext = context;
    int mealsSavedCount = 0;

    // Itera sobre las 5 filas de selecciones
    for (var i = 0; i < _selectedCategories.length; i++) {
      final selectedCategory = _selectedCategories[i];
      final selectedRecipe = _selectedRecipes[i];

      // Verifica si la fila tiene una selección válida
      if (selectedCategory != null && selectedRecipe != null) {
        final success = await _onAddMeal(
          mealCategory: selectedCategory,
          selectedRecipe: selectedRecipe,
        );
        if (success) {
          mealsSavedCount++;
        }
      }
    }

    // Cierra el diálogo antes de mostrar el mensaje (para evitar problemas de contexto)
    if (localContext.mounted) {
      Navigator.pop(localContext);
    }

    if (localContext.mounted) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(
          content: Text(
            mealsSavedCount > 0
                ? '$mealsSavedCount comidas guardadas exitosamente para el día.'
                : 'No se seleccionaron comidas válidas para guardar.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accent1 = Color(0xFFBAA898);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF839788),
        title: const Text('Calendar'),
      ),
      body: Container(
        color: const Color(0xFFEEE0CB),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );
                    _focusedDay = focusedDay;

                    // Resetear selecciones de categoría/meal cada vez que se abre el popup
                    for (var i = 0; i < _selectedCategories.length; i++) {
                      _selectedCategories[i] = null;
                      _selectedRecipes[i] = null;
                    }
                  });

                  Future.delayed(
                    const Duration(milliseconds: 300),
                    () {
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          // === INICIO DEL CAMBIO CLAVE: StatefulBuilder para manejar el estado local del Dialog ===
                          return StatefulBuilder(
                            builder: (BuildContext dialogContext, StateSetter dialogSetState) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEE0CB),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Your meals for today',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 12),

                                      // ===== Dropdowns (5 filas) =====
                                      Consumer<MealDayProvider>(
                                        builder: (context, mealProvider, _) {
                                          if (mealProvider.isLoadingRecipes &&
                                              mealProvider.recipes.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(),
                                            );
                                          }

                                          final categories = mealProvider.availableMealTypes;

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: _buildMealRow(
                                                  rowIndex: index,
                                                  categories: categories,
                                                  mealProvider: mealProvider,
                                                  dialogSetState: dialogSetState, // <<< PASAMOS EL SETSTATE LOCAL
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      // ===== Botones Guardar y Cancelar =====
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext),
                                            child: const Text('Cancel'),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: _onSaveAllMeals, // <-- Llama a la función de guardado en lote
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF839788),
                                            ),
                                            child: const Text('Save Meals'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          // === FIN DEL CAMBIO CLAVE ===
                        },
                      );
                    },
                  );
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() => _calendarFormat = format);
                }
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFF839788),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: accent1,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Consumer<MealDayProvider>(
                builder: (context, mealProvider, _) {
                  if (mealProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_selectedDay == null) {
                    return const Center(child: Text('No day selected'));
                  }

                  final mealsForDay = mealProvider.meals
                      .where((m) =>
                          m.eatDate != null &&
                          isSameDay(m.eatDate, _selectedDay))
                      .toList();

                  if (mealsForDay.isEmpty) {
                    return Center(
                      child: Text(
                        'No meals for ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: mealsForDay.length,
                    itemBuilder: (context, index) {
                      final meal = mealsForDay[index];
                      return ListTile(
                        title: Text(meal.mealCategory ?? 'Sin categoría'),
                        subtitle: meal.ingredients != null &&
                                meal.ingredients!.isNotEmpty
                            ? Text(meal.ingredients!)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// meal row builder function
  Widget _buildMealRow({
    required int rowIndex,
    required List<String> categories,
    required MealDayProvider mealProvider,
    required StateSetter dialogSetState, // <<< NUEVO PARÁMETRO
  }) {
    final String? selectedCategory = _selectedCategories[rowIndex];
    final Recipe? selectedRecipe = _selectedRecipes[rowIndex];

    final List<Recipe> recipesForCategory = selectedCategory == null
        ? <Recipe>[]
        : mealProvider.recipesForMealType(selectedCategory);

    return Row(
      children: [
        // Dropdown de categoría
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: const Text('Category'),
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: categories
                .map(
                  (cat) => DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  ),
                )
                .toList(),
            onChanged: (value) {
              // === USAMOS dialogSetState EN LUGAR DE setState() ===
              dialogSetState(() {
                _selectedCategories[rowIndex] = value;
                _selectedRecipes[rowIndex] =
                    null; // reset meal al cambiar categoría
              });
            },
          ),
        ),
        const SizedBox(width: 8),

        // Dropdown de meal filtrada por la categoría
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<Recipe>(
            // Si la receta previamente seleccionada ya no está en la nueva categoría, su valor es null
            value: recipesForCategory.contains(selectedRecipe)
                ? selectedRecipe
                : null,
            hint: const Text('Meal'),
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: recipesForCategory
                .map(
                  (recipe) => DropdownMenuItem<Recipe>(
                    value: recipe,
                    child: Text(recipe.title),
                  ),
                )
                .toList(),
            onChanged: (recipe) {
              // === USAMOS dialogSetState EN LUGAR DE setState() ===
              dialogSetState(() {
                _selectedRecipes[rowIndex] = recipe;
              });
            },
          ),
        ),
        // Se ha eliminado el Botón Add individual.
      ],
    );
  }
}