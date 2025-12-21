
import 'package:flutter/material.dart';
import 'package:e_program_apps/widgets/settings_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_program_apps/viewmodel/session_viewmodel.dart';
import 'package:e_program_apps/data/database_helper.dart';
import 'package:e_program_apps/model/user_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // This sets the back arrow color
        elevation: 0,
      ),
      body: FutureBuilder<User?>(
        future: DatabaseHelper().getCachedUser(),
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final user = snapshot.data;
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildProfileCard(user: user, loading: loading),
                const SettingsListItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                ),
                const SettingsListItem(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Manage push and email notifications',
                ),
                const SettingsListItem(
                  icon: Icons.info_outline,
                  title: 'About App',
                  subtitle: 'Version info and app details',
                ),
                SettingsListItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final router = GoRouter.of(context);
    await context.read<SessionViewModel>().logout();
    router.go('/');
  }

  Widget _buildProfileCard({User? user, bool loading = false}) {
    final userName = loading
        ? 'Loading...'
        : _displayValue(user?.userName ?? '', fallback: 'User not found');
    final loginName = loading
        ? 'Please wait'
        : _displayValue(user?.loginName ?? '', fallback: 'N/A');
    final designation = loading
        ? 'Please wait'
        : _displayValue(user?.desigName ?? '', fallback: 'N/A');
    final roleType = loading
        ? 'Please wait'
        : _displayValue(user?.roleType ?? '', fallback: 'N/A');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A2540), Color(0xFF1A3D8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loginName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildChip(designation),
                        _buildChip(roleType),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: Color(0xFF1A3D8A)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1A3D8A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _displayValue(String value, {String fallback = 'N/A'}) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
