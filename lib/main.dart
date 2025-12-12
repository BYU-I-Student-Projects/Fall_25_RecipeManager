// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recipe_manager/providers/recipe_provider.dart';
import 'package:recipe_manager/providers/theme_provider.dart';
import '../providers/calendar_provider.dart';
import 'package:recipe_manager/screens/main_screen.dart';
import 'package:recipe_manager/screens/auth/auth_gate.dart';


final prodSupabaseURL = 'https://uzojyrjxuhigisfvwxni.supabase.co';
final prodSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6b2p5cmp4dWhpZ2lzZnZ3eG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MjUyMTYsImV4cCI6MjA3NTEwMTIxNn0.vRbrEM5IccOdGUYX8MidpyPbnZs8gW5AZ0iFh44hxS4';

Future<void> main() async {
  // Makes sure that all the widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Use kDebugMode to decide which keys to load
  final supabaseUrl = prodSupabaseURL;
  final supabaseAnonKey = prodSupabaseAnonKey;
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  Supabase.instance.client.auth.currentSession; // NEW

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MealDayProvider()), // Ensure this is here from the previous fix
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Recipe App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            // Point to AuthGate so it checks if the user is logged in first
            home: const AuthGate(), 
          );
        },
      ),
    );
  }
}
