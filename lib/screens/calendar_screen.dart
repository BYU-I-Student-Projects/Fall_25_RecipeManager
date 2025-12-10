// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:recipe_manager/providers/theme_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              // Today decoration
              todayDecoration: const BoxDecoration(
                color: Color(0xFF839788),
                shape: BoxShape.circle,
              ),
              // Selected day decoration
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFBAA898),
                shape: BoxShape.circle,
              ),
              // Default text styles
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              outsideTextStyle: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: isDark ? Colors.white : Colors.black,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              weekendStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              // Customize the appearance of calendar cells if needed
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          // You can add a list of events for the selected day here
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
    );
  }
}