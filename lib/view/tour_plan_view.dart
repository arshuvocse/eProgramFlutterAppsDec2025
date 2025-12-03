import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/tour_plan_viewmodel.dart';

const teal = Color(0xFF008080);

class TourPlanView extends StatelessWidget {
  const TourPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TourPlanViewModel(),
      child: Consumer<TourPlanViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tour Plan'),
              backgroundColor: teal,
              foregroundColor: Colors.white,
            ),
            body: Column(
              children: [
                // Header month/year
                Container(
                  color: const Color(0xFFE8F3F3),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(child: _monthPicker(vm)),
                      const SizedBox(width: 12),
                      Expanded(child: _yearPicker(vm)),
                    ],
                  ),
                ),

                // Day selector
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select Day',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: vm.daysInMonth(),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final d = i + 1;
                      final sel = vm.selectedDay == d;
                      return GestureDetector(
                        onTap: () => vm.pickDay(d),
                        child: Container(
                          width: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel ? teal : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: teal, width: 1.25),
                          ),
                          child: Text(
                            '$d',
                            style: TextStyle(
                              color: sel ? Colors.white : teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Providers header + search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      vm.selectedDay == null
                          ? 'Providers'
                          : 'Providers for: ${vm.selectedDateIso}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    onChanged: vm.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search provider',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: teal),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: teal),
                      ),
                    ),
                  ),
                ),

                // Provider list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: vm.providers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = vm.providers[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: CheckboxListTile(
                          value: p.selected,
                          onChanged: (v) => vm.toggleProvider(p.id, v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('Code: ${p.code}',
                                        style: const TextStyle(
                                            color: Colors.black54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(p.orgName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(p.type,
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Bottom actions
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F3F3),
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (await vm.saveDraft() && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Draft saved')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: teal),
                          foregroundColor: teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('SAVE DRAFT'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (vm.selectedDay == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select a day')),
                            );
                            return;
                          }
                          if (await vm.finalSubmit() && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Final submitted')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('FINAL SUBMIT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _monthPicker(TourPlanViewModel vm) {
    return _boxed(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: vm.monthIndex,
          items: List.generate(vm.months.length, (i) {
            return DropdownMenuItem(
              value: i,
              child: Text(vm.months[i]),
            );
          }),
          onChanged: (v) => vm.setMonth(v ?? vm.monthIndex),
        ),
      ),
    );
  }

  Widget _yearPicker(TourPlanViewModel vm) {
    final years = List<int>.generate(7, (i) => vm.year - 3 + i); // year-3..year+3
    return _boxed(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: vm.year,
          items: years
              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .toList(),
          onChanged: (v) => vm.setYear(v ?? vm.year),
        ),
      ),
    );
  }

  Widget _boxed({required Widget child}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: teal),
      ),
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }
}
