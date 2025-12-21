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
            body: RefreshIndicator(
              onRefresh: vm.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 8),
                  _ChipsRow(
                    selected: vm.chip,
                    onSelected: vm.setChip,
                    brand: brand,
                    options: vm.filters,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      onChanged: vm.setQuery,
                      decoration: InputDecoration(
                        hintText: 'Search by name, code, or mobile',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vm.error!,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (vm.loading && filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No providers found')),
                    )
                  else
                    ...[
                      for (final p in filtered)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _ProviderCard(
                            data: p,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChecklistView(provider: p),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
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
  final List<String> options;
  const _ChipsRow({
    required this.selected,
    required this.onSelected,
    required this.brand,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final it in options)
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
                    data.providerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.providerCode,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.programName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(data.mobileNo.isNotEmpty ? data.mobileNo : data.email,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
