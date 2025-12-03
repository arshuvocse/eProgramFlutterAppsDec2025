
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DataSyncScreen extends StatelessWidget {
  const DataSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Data Sync',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSyncItem(context, 'Programs', true),
            const Divider(),
            _buildSyncItem(context, 'Providers', true),
            const Divider(),
            _buildSyncItem(context, 'Training', true),
            const Divider(),
            _buildSyncItem(context, 'Materials', true),
            const SizedBox(height: 30),
            const Text(
              'Last sync: Today 10:38 AM',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3D8A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SYNC NOW',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncItem(BuildContext context, String title, bool isSynced) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.check_circle : Icons.cancel,
            color: isSynced ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            isSynced ? 'Synced' : 'Not Synced',
            style: TextStyle(
              color: isSynced ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
