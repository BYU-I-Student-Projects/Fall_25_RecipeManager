// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recipe_manager/screens/main_screen.dart';

Future<void> main() async {
  // Makes sure that all the widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize supabase with our project URL and anon key
  await Supabase.initialize(
    url: 'https://uzojyrjxuhigisfvwxni.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6b2p5cmp4dWhpZ2lzZnZ3eG5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1MjUyMTYsImV4cCI6MjA3NTEwMTIxNn0.vRbrEM5IccOdGUYX8MidpyPbnZs8gW5AZ0iFh44hxS4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true, 
      ),
      home: MainScreen(),
    );
  }
}