// lib/screens/user_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recipe_manager/providers/theme_provider.dart';
import 'package:recipe_manager/screens/auth/auth_gate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = '';
  String userAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
      userAvatar = prefs.getString('userAvatar') ?? '';
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
    await prefs.setString('userAvatar', userAvatar);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? '';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header for Main Settings
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: _showLogoutDialog,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                children: <Widget>[
                  // Profile Section
                  _buildProfileSection(isDark, userEmail),
                  
                  const Divider(height: 1),
                  
                  // Settings Section
                  _buildSectionHeader('Preferences', isDark),
                  
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme(value);
                      },
                      activeColor: const Color(0xFF839788),
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  _buildSectionHeader('About', isDark),
                  
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileSection(bool isDark, String userEmail) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF839788),
            backgroundImage: userAvatar.isNotEmpty ? NetworkImage(userAvatar) : null,
            child: userAvatar.isEmpty
              ? Text(_getInitials(userName), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
              : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName.isEmpty ? 'Add your name' : userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: userName.isEmpty ? (isDark ? Colors.grey[500] : Colors.grey[600]) : (isDark ? Colors.white : Colors.black))),
                const SizedBox(height: 4),
                Text(userEmail, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(currentName: userName, currentAvatar: userAvatar, userEmail: userEmail)));
              if (result != null) {
                setState(() {
                  userName = result['name'] ?? userName;
                  userAvatar = result['avatar'] ?? userAvatar;
                });
                _saveUserData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    List<String> nameParts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.length >= 2) return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    else if (nameParts.isNotEmpty) return nameParts[0][0].toUpperCase();
    return 'U';
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthGate()), (route) => false);
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
                  }
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// ------------------------------------------------------------------
// Edit Profile Screen (FIXED: Removed AppBar, added Custom Header)
// ------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentAvatar;
  final String userEmail;
  
  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentAvatar,
    required this.userEmail,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.userEmail);
    _avatarUrl = widget.currentAvatar;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  void _saveProfile() async {
      if (_formKey.currentState!.validate()) {
          final newEmail = _emailController.text.trim();
          final currentUser = Supabase.instance.client.auth.currentUser;
          
          if (newEmail != widget.userEmail && currentUser != null) {
               try {
                   await Supabase.instance.client.auth.updateUser(UserAttributes(email: newEmail));
                   if (!mounted) return;
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated! Check your new email to confirm the change.'), duration: Duration(seconds: 4)));
               } catch (e) {
                   if (!mounted) return;
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating email: $e')));
                   return;
               }
          }
          Navigator.pop(context, {'name': _nameController.text, 'avatar': _avatarUrl});
          if (newEmail == widget.userEmail) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
          }
      }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    List<String> nameParts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.length >= 2) return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    else if (nameParts.isNotEmpty) return nameParts[0][0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
      final theme = Theme.of(context);
      return Scaffold(
          // No AppBar
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: _saveProfile,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                      child: Padding(padding: const EdgeInsets.all(16.0), child: Form(key: _formKey, child: Column(children: [
                          Stack(children: [
                              CircleAvatar(radius: 60, backgroundColor: const Color(0xFF839788), backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null, child: _avatarUrl.isEmpty ? Text(_getInitials(_nameController.text.isNotEmpty ? _nameController.text : 'User'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)) : null),
                              Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.white, radius: 20, child: IconButton(icon: const Icon(Icons.camera_alt, size: 20), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker not implemented yet'))); })))
                          ]),
                          const SizedBox(height: 32),
                          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), hintText: 'Enter your name'), onChanged: (value) { if (mounted) setState(() {}); }, validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), hintText: 'Enter your email'), keyboardType: TextInputType.emailAddress, validator: (value) { if (value == null || value.isEmpty) return 'Please enter your email'; if (!value.contains('@')) return 'Please enter a valid email'; return null; }),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change password feature coming soon'))); }, icon: const Icon(Icons.lock), label: const Text('Change Password'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24))),
                      ])))
                  ),
                ),
              ],
            ),
          )
      );
  }
}

// ------------------------------------------------------------------
// About Screen (FIXED: Removed AppBar, added Custom Header)
// ------------------------------------------------------------------
class AboutScreen extends StatelessWidget {
    const AboutScreen({super.key});
    @override
    Widget build(BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'About',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                Expanded(
                  child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Center(child: Icon(Icons.restaurant_menu, size: 80, color: Color(0xFF839788))),
                      const SizedBox(height: 24),
                      Center(child: Text('Recipe App', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      Center(child: Text('Version 1.0.0', style: Theme.of(context).textTheme.bodyMedium)),
                      const SizedBox(height: 32),
                      Text('About This App', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Recipe App is your personal cooking companion, designed to help you discover, organize, and create delicious meals. Whether you\'re a beginner cook or a seasoned chef, our app makes it easy to find recipes, plan your meals, and build your grocery list.', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      Text('Features', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildFeatureItem('📖 Browse and search thousands of recipes', context),
                      _buildFeatureItem('🛒 Create and manage grocery lists', context),
                      _buildFeatureItem('📅 Plan your meals with our calendar feature', context),
                      _buildFeatureItem('💾 Save your favorite recipes', context),
                      _buildFeatureItem('🌙 Dark mode support for comfortable viewing', context),
                      const SizedBox(height: 24),
                      Text('Contact Us', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Have questions or feedback? We\'d love to hear from you!', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      const Text('Email: support@recipeapp.com', style: TextStyle(fontSize: 16, color: Color(0xFF839788))),
                      const SizedBox(height: 32),
                      Center(child: Text('© 2025 Recipe App. All rights reserved.', style: Theme.of(context).textTheme.bodySmall)),
                  ])),
                ),
              ],
            ),
          )
        );
    }
    
    Widget _buildFeatureItem(String text, BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      );
    }
}

// ------------------------------------------------------------------
// Privacy Policy Screen (FIXED: Removed AppBar, added Custom Header)
// ------------------------------------------------------------------
class PrivacyPolicyScreen extends StatelessWidget {
    const PrivacyPolicyScreen({super.key});
    @override
    Widget build(BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                Expanded(
                  child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Privacy Policy', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Last Updated: December 2025', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 24),
                      _buildSection(context, 'Introduction', 'Welcome to Recipe App. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our mobile application.'),
                      _buildSection(context, 'Information We Collect', 'We collect information that you provide directly to us, including:\n\n• Account information (name, email address)\n• Profile information and preferences\n• Recipes you save or create\n• Grocery lists and meal plans\n• Usage data and app interactions'),
                      _buildSection(context, 'How We Use Your Information', 'We use the information we collect to:\n\n• Provide and maintain our services\n• Personalize your experience\n• Send you important updates and notifications\n• Improve our app and develop new features\n• Ensure the security of our services'),
                      _buildSection(context, 'Data Storage and Security', 'Your data is stored securely using industry-standard encryption. We use Supabase as our backend service provider, which implements robust security measures to protect your information. We do not sell your personal data to third parties.'),
                      _buildSection(context, 'Your Rights', 'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Delete your account and data\n• Export your data\n• Opt-out of marketing communications'),
                      _buildSection(context, 'Cookies and Tracking', 'We use essential cookies and similar technologies to provide and improve our services. These help us understand how you use our app and enhance your experience.'),
                      _buildSection(context, 'Children\'s Privacy', 'Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.'),
                      _buildSection(context, 'Changes to This Policy', 'We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the "Last Updated" date.'),
                      _buildSection(context, 'Contact Us', 'If you have any questions about this privacy policy or our data practices, please contact us at:\n\nEmail: privacy@recipeapp.com'),
                      const SizedBox(height: 24),
                      Center(child: Text('© 2025 Recipe App. All rights reserved.', style: Theme.of(context).textTheme.bodySmall)),
                  ])),
                ),
              ],
            ),
          )
        );
    }
    
    Widget _buildSection(BuildContext context, String title, String content) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(content, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }
}