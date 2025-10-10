// lib/screens/calendar_screen.dart

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
            selectedDayPredicate: (day) {
              // Use `isSameDay` for comparison to handle DateTime differences
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
            // Optional: Customize appearance and behavior
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF839788),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: (accent1),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // Hide the format button if not needed
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8.0),
          // You can add a list of events for the selected day here
          Expanded(
            child: Center(
              child: _selectedDay != null
                  ? Text('Selected day: ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}')
                  : const Text('No day selected'),
            ),
          ),
        ],
      ),
    )
    );
  }
}
