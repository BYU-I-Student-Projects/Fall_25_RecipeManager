// lib/screens/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main_screen.dart';
import '../login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While Supabase is restoring the session from storage
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Prefer session from the stream, fall back to currentSession
        final session = snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          // User already logged in -> go straight to main app
          return const MainScreen();
        }

        // No session -> show login screen
        return const UserLogin();
      },
    );
  }
}


