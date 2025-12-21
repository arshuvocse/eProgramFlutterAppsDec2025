
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodel/data_sync_viewmodel.dart';

class DataSyncScreen extends StatelessWidget {
  const DataSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataSyncViewModel()..init(),
      child: const _DataSyncView(),
    );
  }
}

class _DataSyncView extends StatelessWidget {
  const _DataSyncView();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataSyncViewModel>(
      builder: (context, viewModel, child) {
        final items = viewModel.items;
        final errorMessage = viewModel.errorMessage?.trim();
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
                  for (int i = 0; i < items.length; i++) ...[
                    _buildSyncItem(items[i].title, items[i].synced),
                    if (i != items.length - 1) const Divider(),
                  ],
                  const SizedBox(height: 30),
                  Text(
                    'Last sync: ${_formatLastSync(viewModel.lastSync)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.loading) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3D8A)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Syncing data...',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ] else if (errorMessage != null && errorMessage.isNotEmpty) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Spacer(),
                  if (viewModel.syncCompleted)
                    ElevatedButton(
                      onPressed: () => GoRouter.of(context).go('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3D8A),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Not synced yet';
    final local = time.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day}/${local.month}/${local.year} $hour:$minute $amPm';
  }

  Widget _buildSyncItem(String title, bool isSynced) {
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
