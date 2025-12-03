import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/provider_model.dart';
import '../viewmodel/providers_viewmodel.dart';
import 'checklist_view.dart';

class ProvidersListView extends StatelessWidget {
  const ProvidersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = const Color(0xFF008080);
    return ChangeNotifierProvider(
      create: (_) => ProvidersViewModel()..init(),
      child: Consumer<ProvidersViewModel>(
        builder: (context, vm, _) {
          final filtered = vm.providers;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              title: const Text('Providers'),
            ),
            body: Column(
              children: [
                const SizedBox(height: 8),
                _ChipsRow(
                  selected: vm.chip,
                  onSelected: vm.setChip,
                  brand: brand,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    onChanged: vm.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _ProviderCard(
                      data: filtered[i],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChecklistView(provider: filtered[i]),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final Color brand;
  const _ChipsRow({
    required this.selected,
    required this.onSelected,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    const items = ['All', 'Blue Star', 'Green Star', 'Silver'];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                selectedColor: brand.withValues(alpha: .15),
                label: Text(it),
                selected: selected == it,
                onSelected: (_) => onSelected(it),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel data;
  final VoidCallback onTap;
  const _ProviderCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.code,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.category,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(data.type, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
