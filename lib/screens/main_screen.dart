// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import '/../screens/recipe_list_screen.dart';
import '/../screens/grocery_list_screen.dart';
import '/../screens/calendar_screen.dart';
import '/../screens/user_settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // This integer will track the currently selected tab.
  int _selectedIndex = 0; 

  // This is the list of screens/widgets to display for each tab.
  static const List<Widget> _widgetOptions = <Widget>[
    RecipeListScreen(),
    GroceryListScreen(),
    Scaffold(body: Center(child: Text('Create Recipe Screen'))),
    CalendarScreen(),
    SettingsScreen(),
  ]; 

  // This function is called when a tab is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the widget from our list based on the selected index.
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFBAA898),
        type: BottomNavigationBarType.fixed, // Ensures all items are shown
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Grocery List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Recipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex, // Highlights the correct tab
        selectedItemColor: const Color(0xFFFFFFFF), // Or preferred color
        onTap: _onItemTapped, // Calls when a tab is tapped
      ),
    );
  }
}