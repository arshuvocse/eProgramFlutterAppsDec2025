import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _dashboardPrimary = Color(0xFF008080);
const _dashboardSecondary = Color(0xFF0A2540);

class ChecklistResponseView extends StatefulWidget {
  const ChecklistResponseView({super.key});

  @override
  State<ChecklistResponseView> createState() => _ChecklistResponseViewState();
}

class _ChecklistResponseViewState extends State<ChecklistResponseView> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final List<_VisitedProvider> _allProviders = [
    _VisitedProvider(
      name: 'Provider A',
      location: 'Dhaka',
      visitedOn: DateTime(2024, 7, 1),
    ),
    _VisitedProvider(
      name: 'Provider B',
      location: 'Chattogram',
      visitedOn: DateTime(2024, 7, 3),
    ),
    _VisitedProvider(
      name: 'Provider C',
      location: 'Sylhet',
      visitedOn: DateTime(2024, 7, 5),
    ),
    _VisitedProvider(
      name: 'Provider D',
      location: 'Khulna',
      visitedOn: DateTime(2024, 7, 8),
    ),
  ];

  List<_VisitedProvider> _results = [];

  @override
  void initState() {
    super.initState();
    _results = _allProviders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_dashboardSecondary, _dashboardPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Checklist Response',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'From',
                    value: _fromDate,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'To',
                    value: _toDate,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Visited Providers',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _dashboardSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _dashboardPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _results.length.toString(),
                    style: const TextStyle(
                      color: _dashboardPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No visited providers found.'))
                  : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                          final item = _results[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text(item.location),
                            trailing: Text(
                              MaterialLocalizations.of(context)
                                  .formatMediumDate(item.visitedOn),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initialDate = isFrom ? (_fromDate ?? now) : (_toDate ?? now);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromDate = selected;
        } else {
          _toDate = selected;
        }
      });
    }
  }

  void _search() {
    if (_fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From date cannot be after To date.')),
      );
      return;
    }

    final filtered = _allProviders.where((provider) {
      final date = provider.visitedOn;
      if (_fromDate != null && date.isBefore(_startOfDay(_fromDate!))) {
        return false;
      }
      if (_toDate != null && date.isAfter(_endOfDay(_toDate!))) {
        return false;
      }
      return true;
    }).toList();

    setState(() {
      _results = filtered;
    });
  }

  DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

class _VisitedProvider {
  final String name;
  final String location;
  final DateTime visitedOn;

  const _VisitedProvider({
    required this.name,
    required this.location,
    required this.visitedOn,
  });
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select date'
        : MaterialLocalizations.of(context).formatMediumDate(value!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
