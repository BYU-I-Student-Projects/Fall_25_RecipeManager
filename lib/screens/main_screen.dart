// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import '/../screens/recipe_list_screen.dart';
// import 'shopping_list_screen.dart';
// import 'profile_screen.dart';

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
    // TODO: Replace the placeholders below with actual screen widgets
    Scaffold(body: Center(child: Text('Shopping List Screen'))), 
    Scaffold(body: Center(child: Text('Create Recipe Screen'))),
    Scaffold(body: Center(child: Text('Calendar Screen'))),
    Scaffold(body: Center(child: Text('Settings Screen'))),
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
        selectedItemColor: Theme.of(context).primaryColor, // Or preferred color
        onTap: _onItemTapped, // Calls when a tab is tapped
      ),
    );
  }
}