import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/provider_model.dart';
import '../viewmodel/checklist_viewmodel.dart';

class ChecklistView extends StatelessWidget {
  final ProviderModel provider;
  const ChecklistView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final brand = const Color(0xFF008080);
    return ChangeNotifierProvider(
      create: (_) => ChecklistViewModel(provider: provider),
      child: Consumer<ChecklistViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              title: const Text('Check List'),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await vm.submit();
                      final snack = SnackBar(
                        content: const Text('Checklist saved locally (demo).'),
                        behavior: SnackBarBehavior.floating,
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(snack);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit Checklist'),
                  ),
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _ProviderHeader(provider: provider),
                const SizedBox(height: 16),
                const Text(
                  'GSP Visit Checklist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),

                for (final q in vm.questions) ...[
                  _qTitle('${q.id}. ${q.text}'),
                  _radioGroup(
                    value: q.answer,
                    onChanged: (v) => vm.setAnswer(q.id, v),
                    options: q.options,
                    axis: q.options.length <= 2 ? Axis.horizontal : Axis.vertical,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
      );

  Widget _radioGroup({
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
    Axis axis = Axis.vertical,
  }) {
    return Wrap(
      direction: axis == Axis.vertical ? Axis.vertical : Axis.horizontal,
      spacing: 24,
      runSpacing: -8,
      children: [
        for (final o in options)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(value: o, groupValue: value, onChanged: onChanged),
              Text(o),
            ],
          ),
      ],
    );
  }
}

class _ProviderHeader extends StatelessWidget {
  final ProviderModel provider;
  const _ProviderHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text('Code: ${provider.code}'),
                const SizedBox(height: 4),
                Text(provider.phone),
              ],
            ),
            Text(
              provider.category,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
