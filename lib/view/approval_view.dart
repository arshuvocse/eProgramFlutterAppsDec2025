
import 'package:flutter/material.dart';
import 'package:e_program_apps/widgets/settings_list_item.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          SettingsListItem(
            icon: Icons.calendar_today,
            title: 'Attendance',
            subtitle: 'Review and approve attendance records',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.people_outline,
            title: 'Providers',
            subtitle: 'Manage and approve provider requests',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.location_on_outlined,
            title: 'Tour Plan',
            subtitle: 'Approve or reject proposed tour plans',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.playlist_add_check,
            title: 'Checklist',
            subtitle: 'Review and approve completed checklists',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.approval,
            title: 'General Approvals',
            subtitle: 'Handle other pending approvals',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.list,
            title: 'View All',
            subtitle: 'See a complete list of all approvals',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
