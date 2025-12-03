
import 'package:flutter/material.dart';
import 'package:e_program_apps/widgets/settings_list_item.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          SettingsListItem(
            icon: Icons.bar_chart,
            title: 'Sales Report',
            subtitle: 'View and analyze sales performance',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.pie_chart,
            title: 'Expense Report',
            subtitle: 'Track and manage business expenses',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.trending_up,
            title: 'Performance Report',
            subtitle: 'Monitor and evaluate team performance',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.inventory_2_outlined,
            title: 'Inventory Report',
            subtitle: 'Keep track of stock and inventory levels',
            onTap: () {},
          ),
          SettingsListItem(
            icon: Icons.summarize_outlined,
            title: 'Summary Report',
            subtitle: 'Get a comprehensive overview of all activities',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
