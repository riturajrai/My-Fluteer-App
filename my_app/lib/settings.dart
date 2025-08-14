import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text('Account'),
            subtitle: const Text('Manage your account settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account settings tapped!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.teal),
            title: const Text('Notifications'),
            subtitle: const Text('Customize your notification preferences'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings tapped!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens, color: Colors.teal),
            title: const Text('Theme'),
            subtitle: const Text('Change app appearance'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme settings tapped!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.teal),
            title: const Text('Privacy'),
            subtitle: const Text('Review privacy settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings tapped!')),
              );
            },
          ),
        ],
      ),
    );
  }
}