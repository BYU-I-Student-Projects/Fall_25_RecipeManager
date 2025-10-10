//lib/screens/user_settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                  // Implement logic to change app theme
                });
              },
            ),
          ),
          ListTile(
            title: Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                  // Implement logic to change app language
                });
              },
              items: <String>['English', 'Spanish', 'French', 'German']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Notifications'),
            onTap: () {
              // Navigate to a separate notification settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Show an about dialog or navigate to an about screen
              showAboutDialog(
                context: context,
                applicationName: 'My App',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}

// Example of a separate screen for notification settings
class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Center(
        child: Text('Customize your notification preferences here.'),
      ),
    );
  }
}



