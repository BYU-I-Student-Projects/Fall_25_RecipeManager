import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Variables para guardar la selección de cada meal (inician como null)
  String? _breakfastSelection;
  String? _lunchSelection;
  String? _dinnerSelection;
  String? _snackSelection;
  String? _dessertSelection;

  final List<String> _mealTypes = [
    'All',
    'Breakfast',
    'Brunch',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

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
                  });

                  Future.delayed(
                    const Duration(milliseconds: 300),
                    () {
                      showDialog(
                        context: context,
                        builder: (context) {
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

                                  // ===== Dropdowns =====
                                  _buildMealRow(
                                    value: _breakfastSelection,
                                    onChanged: (value) => setState(() {
                                      _breakfastSelection = value;
                                      print('Selected Breakfast: $value');
                                      // call supabase here
                                    }),
                                    onAdd: () =>
                                        print('Add pressed for $_breakfastSelection'),
                                  ),
                                  const SizedBox(height: 12),

                                  _buildMealRow(
                                    value: _lunchSelection,
                                    onChanged: (value) => setState(() {
                                      _lunchSelection = value;
                                      print('Selected Lunch: $value');
                                    }),
                                    onAdd: () =>
                                        print('Add pressed for $_lunchSelection'),
                                  ),
                                  const SizedBox(height: 12),

                                  _buildMealRow(
                                    value: _dinnerSelection,
                                    onChanged: (value) => setState(() {
                                      _dinnerSelection = value;
                                      print('Selected Dinner: $value');
                                    }),
                                    onAdd: () =>
                                        print('Add pressed for $_dinnerSelection'),
                                  ),
                                  const SizedBox(height: 12),

                                  _buildMealRow(
                                    value: _snackSelection,
                                    onChanged: (value) => setState(() {
                                      _snackSelection = value;
                                      print('Selected Snack: $value');
                                    }),
                                    onAdd: () =>
                                        print('Add pressed for $_snackSelection'),
                                  ),
                                  const SizedBox(height: 12),

                                  _buildMealRow(
                                    value: _dessertSelection,
                                    onChanged: (value) => setState(() {
                                      _dessertSelection = value;
                                      print('Selected Dessert: $value');
                                    }),
                                    onAdd: () =>
                                        print('Add pressed for $_dessertSelection'),
                                  ),
                                  const SizedBox(height: 20),

                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF839788),
                                    ),
                                    child: const Text('Close'),
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
              child: Center(
                child: _selectedDay != null
                    ? Text(
                        'Selected day: ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                      )
                    : const Text('No day selected'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// meal row builder function
  Widget _buildMealRow({
    required String? value,
    required Function(String?) onChanged,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            hint: const Text('Select a meal'),
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
            items: _mealTypes
                .map(
                  (meal) => DropdownMenuItem(
                    value: meal,
                    child: Text(meal),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAdd,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
