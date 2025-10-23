// lib/main.dart


import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recipe_manager/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

Future<void> main() async {
  // Makes sure that all the widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Use kDebugMode to decide which keys to load
  final supabaseUrl = kDebugMode
      ? dotenv.env['LOCAL_SUPABASE_URL']!
      : dotenv.env['PROD_SUPABASE_URL']!;
  final supabaseAnonKey = kDebugMode
      ? dotenv.env['LOCAL_SUPABASE_ANON_KEY']!
      : dotenv.env['PROD_SUPABASE_ANON_KEY']!;
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: MaterialApp(
        title: 'Recipe App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
          useMaterial3: true, 
        ),
        home: MainScreen(),
      ),
    );
  }
}