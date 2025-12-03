import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _dashboardPrimary = Color(0xFF008080);
const _dashboardSecondary = Color(0xFF0A2540);
const _dashboardBg = Color(0xFFF5F7FB);

class TrainingView extends StatelessWidget {
  const TrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _TrainingItem(
        title: 'Participant List',
        icon: Icons.people_outline,
        onTap: (ctx) => _openParticipantList(ctx),
      ),
      _TrainingItem(
        title: 'Add Trainer',
        icon: Icons.person_add_alt_1_outlined,
        onTap: (ctx) => _openAddTrainer(ctx),
      ),
      _TrainingItem(
        title: 'Cost Entry',
        icon: Icons.receipt_long_outlined,
        onTap: (ctx) => _openCostEntry(ctx),
      ),
      _TrainingItem(
        title: 'Material & Remarks',
        icon: Icons.note_alt_outlined,
        onTap: (ctx) => _openMaterialRemarks(ctx),
      ),
    ];

    return Scaffold(
      backgroundColor: _dashboardBg,
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
          'Training',
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
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _TrainingCard(item: item);
          },
        ),
      ),
    );
  }

  void _openCostEntry(BuildContext context) {
    final particulars = ['Hall Rent', 'Food', 'Stationery', 'Transport', 'Others'];
    final List<_CostEntry> costs = [
      _CostEntry(
        particularName: 'Hall Rent',
        value: 25000,
        attachment: 'No file selected.',
        description: '',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void addRow() {
              setSheetState(() {
                costs.add(
                  _CostEntry(
                    particularName: particulars.first,
                    value: 0,
                    attachment: 'No file selected.',
                    description: '',
                  ),
                );
              });
            }

            void removeRow(int index) {
              setSheetState(() {
                if (costs.length > 1) {
                  costs.removeAt(index);
                }
              });
            }

            void clearAll() {
              setSheetState(() {
                costs
                  ..clear()
                  ..add(
                    _CostEntry(
                      particularName: particulars.first,
                      value: 0,
                      attachment: 'No file selected.',
                      description: '',
                    ),
                  );
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Cost Entry',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _dashboardSecondary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: costs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cost = costs[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'SL ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: _dashboardSecondary,
                                          ),
                                        ),
                                        const Spacer(),
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: _dashboardPrimary.withValues(alpha: 0.12),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            icon: const Icon(Icons.add, color: _dashboardPrimary),
                                            onPressed: addRow,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.red.withValues(alpha: 0.12),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        icon: const Icon(Icons.remove, color: Colors.red),
                                        onPressed: () => removeRow(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Particular Name',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                value: cost.particularName,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                items: particulars
                                                    .map(
                                                      (p) => DropdownMenuItem(
                                                        value: p,
                                                        child: Text(p),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setSheetState(() {
                                                    cost.particularName = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 140,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Value',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                initialValue: cost.value.toString(),
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  final parsed = int.tryParse(val) ?? 0;
                                                  setSheetState(() {
                                                    cost.value = parsed;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Attachments',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  OutlinedButton(
                                                    onPressed: () {
                                                      setSheetState(() {
                                                        cost.attachment = 'Selected file';
                                                      });
                                                    },
                                                    child: const Text('Browse'),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      cost.attachment,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Descriptions',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 6),
                                              TextFormField(
                                                initialValue: cost.description,
                                                decoration: InputDecoration(
                                                  hintText: 'Optional',
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  setSheetState(() {
                                                    cost.description = val;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _dashboardPrimary.withValues(alpha: 0.08),
                              foregroundColor: _dashboardPrimary,
                              side: const BorderSide(color: _dashboardPrimary),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Draft saved')),
                              );
                            },
                            child: const Text('Draft'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: _dashboardSecondary,
                            ),
                            onPressed: clearAll,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openMaterialRemarks(BuildContext context) {
    final products = [
      'Bag (from material master)',
      'Notebook',
      'Pen',
      'Banner',
    ];
    final List<_MaterialEntry> materials = [
      _MaterialEntry(product: products.first, quantity: 3),
    ];
    final remarksController = TextEditingController();
    final totalAttendedController = TextEditingController(text: '0');
    String attachment = 'No file selected.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void addRow() {
              setSheetState(() {
                materials.add(
                  _MaterialEntry(product: products.first, quantity: 1),
                );
              });
            }

            void removeRow(int index) {
              if (materials.length <= 1) return;
              setSheetState(() {
                materials.removeAt(index);
              });
            }

            void clearAll() {
              setSheetState(() {
                materials
                  ..clear()
                  ..add(_MaterialEntry(product: products.first, quantity: 1));
                remarksController.clear();
                totalAttendedController.text = '0';
                attachment = 'No file selected.';
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Material List (Consumption-only)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _dashboardSecondary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: materials.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final entry = materials[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'SL ${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: _dashboardSecondary,
                                                ),
                                              ),
                                              const Spacer(),
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: _dashboardPrimary.withValues(alpha: 0.12),
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 18,
                                                  icon: const Icon(Icons.add, color: _dashboardPrimary),
                                                  onPressed: addRow,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Colors.red.withValues(alpha: 0.12),
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 18,
                                                  icon: const Icon(Icons.remove, color: Colors.red),
                                                  onPressed: () => removeRow(index),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Product',
                                                      style: TextStyle(fontWeight: FontWeight.w600),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    DropdownButtonFormField<String>(
                                                      value: entry.product,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      items: products
                                                          .map(
                                                            (p) => DropdownMenuItem(
                                                              value: p,
                                                              child: Text(p),
                                                            ),
                                                          )
                                                          .toList(),
                                                      onChanged: (value) {
                                                        if (value == null) return;
                                                        setSheetState(() {
                                                          entry.product = value;
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Quantity',
                                                      style: TextStyle(fontWeight: FontWeight.w600),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor: _dashboardPrimary.withValues(alpha: 0.12),
                                                          child: IconButton(
                                                            padding: EdgeInsets.zero,
                                                            iconSize: 18,
                                                            icon: const Icon(Icons.add, color: _dashboardPrimary),
                                                            onPressed: () {
                                                              setSheetState(() {
                                                                entry.quantity += 1;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey.shade300),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(entry.quantity.toString()),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor: Colors.red.withValues(alpha: 0.12),
                                                          child: IconButton(
                                                            padding: EdgeInsets.zero,
                                                            iconSize: 18,
                                                            icon: const Icon(Icons.remove, color: Colors.red),
                                                            onPressed: () {
                                                              setSheetState(() {
                                                                entry.quantity = (entry.quantity - 1).clamp(0, 9999);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Remarks & Attendance Sheet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _dashboardSecondary,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Remark',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: remarksController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Free Text',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Attachment',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setSheetState(() {
                                        attachment = 'Selected file';
                                      });
                                    },
                                    child: const Text('Browse'),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      attachment,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Max size 10 MB, document/image (JPEG, PNG, PDF).',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Total Training Attended person',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 220,
                                child: TextField(
                                  controller: totalAttendedController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _dashboardPrimary.withValues(alpha: 0.08),
                              foregroundColor: _dashboardPrimary,
                              side: const BorderSide(color: _dashboardPrimary),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Draft saved')),
                              );
                            },
                            child: const Text('Draft'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: _dashboardSecondary,
                            ),
                            onPressed: clearAll,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAddTrainer(BuildContext context) {
    final nameController = TextEditingController();
    TrainerType selectedType = TrainerType.internal;
    final List<_Trainer> trainers = [
      _Trainer(name: 'Mr. X', type: TrainerType.internal),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void addTrainer() {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  const SnackBar(content: Text('Please enter trainer name')),
                );
                return;
              }
              setSheetState(() {
                trainers.add(_Trainer(name: name, type: selectedType));
                nameController.clear();
                selectedType = TrainerType.internal;
              });
            }

            void removeTrainer(int index) {
              setSheetState(() {
                trainers.removeAt(index);
              });
            }

            void clearForm() {
              setSheetState(() {
                nameController.clear();
                selectedType = TrainerType.internal;
                trainers.clear();
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add Trainer',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _dashboardSecondary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Trainer Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _dashboardSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Free Text',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Radio<TrainerType>(
                            value: TrainerType.internal,
                            groupValue: selectedType,
                            activeColor: _dashboardPrimary,
                            onChanged: (value) {
                              if (value != null) {
                                setSheetState(() {
                                  selectedType = value;
                                });
                              }
                            },
                          ),
                          const Text('Internal'),
                          const SizedBox(width: 12),
                          Radio<TrainerType>(
                            value: TrainerType.external,
                            groupValue: selectedType,
                            activeColor: _dashboardPrimary,
                            onChanged: (value) {
                              if (value != null) {
                                setSheetState(() {
                                  selectedType = value;
                                });
                              }
                            },
                          ),
                          const Text('External'),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _dashboardPrimary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: addTrainer,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width - 64,
                                ),
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F6FB)),
                                    columns: const [
                                      DataColumn(label: Text('SL')),
                                      DataColumn(label: Text('Trainer Name')),
                                      DataColumn(label: Text('Trainer Type')),
                                      DataColumn(label: Text('Action')),
                                    ],
                                    rows: List.generate(trainers.length, (index) {
                                      final trainer = trainers[index];
                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(trainer.name)),
                                          DataCell(Text(trainer.type == TrainerType.internal ? 'Internal' : 'External')),
                                          DataCell(
                                            IconButton(
                                              onPressed: () => removeTrainer(index),
                                              icon: const Icon(Icons.remove_circle_outline),
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _dashboardPrimary.withValues(alpha: 0.08),
                              foregroundColor: _dashboardPrimary,
                              side: const BorderSide(color: _dashboardPrimary),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Draft saved')),
                              );
                            },
                            child: const Text('Draft'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: _dashboardSecondary,
                            ),
                            onPressed: clearForm,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openParticipantList(BuildContext context) {
    final participants = <_Participant>[
      _Participant(
        code: 'BSP15844',
        traineeName: 'Md. Abu Taleb',
        gender: 'MALE',
        division: 'Khulna',
        district: 'Kushtia',
        upazila: 'Kushtia Sadar',
        address: 'Boro Bazar',
        outlet: '3 Brothers Medicine',
        mobile: '8801XXXXXXXX',
        poTsd: 'Anwar',
        lastUpdated: DateTime(2025, 8, 24),
        isActive: true,
      ),
      _Participant(
        code: 'TES77',
        traineeName: 'Swarajit Chandra Singh',
        gender: 'MALE',
        division: 'Dhaka',
        district: 'Dhaka',
        upazila: 'Vatara',
        address: 'Vatara, Notun Bazar',
        outlet: '71 Pharmacy',
        mobile: '8801XXXXXXXX',
        poTsd: 'Tanjibul Abedin',
        lastUpdated: DateTime(2022, 9, 11),
        isActive: true,
      ),
      _Participant(
        code: 'T02514',
        traineeName: 'Md. Al Amin',
        gender: 'MALE',
        division: 'Dhaka',
        district: 'Narayanganj',
        upazila: 'Fatullah',
        address: 'Bhuiyghar, Fatulla',
        outlet: 'A Amin Pharmacy',
        mobile: '8801XXXXXXXX',
        poTsd: 'Khairul Alam',
        lastUpdated: DateTime(2022, 8, 6),
        isActive: true,
      ),
    ];

    final teams = participants.map((p) => p.poTsd).toSet().toList();
    DateTime? fromDate;
    DateTime? toDate;
    String? selectedTeam;
    List<_Participant> filtered = List.of(participants);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> pickDate({required bool isFrom}) async {
              final now = DateTime.now();
              final initial = isFrom ? (fromDate ?? now) : (toDate ?? now);
              final selected = await showDatePicker(
                context: sheetContext,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year + 2),
              );
              if (selected != null) {
                setSheetState(() {
                  if (isFrom) {
                    fromDate = selected;
                  } else {
                    toDate = selected;
                  }
                });
              }
            }

            void applyFilter() {
              if (fromDate != null && toDate != null && fromDate!.isAfter(toDate!)) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  const SnackBar(content: Text('From date cannot be after To date')),
                );
                return;
              }

              List<_Participant> next = participants.where((p) {
                final date = p.lastUpdated;
                if (fromDate != null && date.isBefore(_startOfDay(fromDate!))) return false;
                if (toDate != null && date.isAfter(_endOfDay(toDate!))) return false;
                if (selectedTeam != null && selectedTeam!.isNotEmpty && p.poTsd != selectedTeam) {
                  return false;
                }
                return true;
              }).toList();

              setSheetState(() {
                filtered = next;
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Participant List',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _dashboardSecondary,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _FilterDateField(
                              label: 'Training Date (From)',
                              value: fromDate,
                              onTap: () => pickDate(isFrom: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FilterDateField(
                              label: 'Training Date (To)',
                              value: toDate,
                              onTap: () => pickDate(isFrom: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Training Team',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        value: selectedTeam,
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('All Teams'),
                          ),
                          ...teams.map(
                            (team) => DropdownMenuItem(
                              value: team,
                              child: Text(team),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            selectedTeam = value?.isEmpty ?? true ? null : value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: applyFilter,
                          icon: const Icon(Icons.filter_alt_outlined),
                          label: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Attendance',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _dashboardSecondary,
                                ),
                          ),
                          const Spacer(),
                          const Text('Select All'),
                          Checkbox(
                            value: filtered.every((p) => p.selected) && filtered.isNotEmpty,
                            tristate: true,
                            onChanged: (value) {
                              final bool next =
                                  value == true ? true : value == false ? false : !filtered.every((p) => p.selected);
                              setSheetState(() {
                                for (final p in filtered) {
                                  p.selected = next;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No participants found.'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final p = filtered[index];

                                  Widget infoRow(String label, String value) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 130,
                                            child: Text(
                                              label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: _dashboardSecondary,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              value,
                                              style: const TextStyle(color: _dashboardSecondary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Code: ${p.code}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: _dashboardSecondary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: p.isActive
                                                      ? _dashboardPrimary.withValues(alpha: 0.12)
                                                      : Colors.red.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  p.isActive ? 'Active' : 'Inactive',
                                                  style: TextStyle(
                                                    color: p.isActive ? _dashboardPrimary : Colors.red,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              const Text('Select'),
                                              Checkbox(
                                                value: p.selected,
                                                onChanged: (value) {
                                                  setSheetState(() {
                                                    p.selected = value ?? false;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          infoRow('Trainee Name', p.traineeName),
                                          infoRow('Gender', p.gender),
                                          infoRow('Division', p.division),
                                          infoRow('District', p.district),
                                          infoRow('Upazila', p.upazila),
                                          infoRow('Address', p.address),
                                          infoRow('Outlet', p.outlet),
                                          infoRow('Mobile', p.mobile),
                                          infoRow('PO-TSD', p.poTsd),
                                          infoRow('Last Updated', _formatDate(p.lastUpdated)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _dashboardPrimary.withValues(alpha: 0.08),
                              foregroundColor: _dashboardPrimary,
                              side: const BorderSide(color: _dashboardPrimary),
                            ),
                            onPressed: () {},
                            child: const Text('Draft'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}

class _TrainingItem {
  final String title;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  const _TrainingItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _TrainingCard extends StatelessWidget {
  final _TrainingItem item;

  const _TrainingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => item.onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _dashboardPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: _dashboardPrimary,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _dashboardSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Participant {
  final String code;
  final String traineeName;
  final String gender;
  final String division;
  final String district;
  final String upazila;
  final String address;
  final String outlet;
  final String mobile;
  final String poTsd;
  final DateTime lastUpdated;
  final bool isActive;
  bool selected;

  _Participant({
    required this.code,
    required this.traineeName,
    required this.gender,
    required this.division,
    required this.district,
    required this.upazila,
    required this.address,
    required this.outlet,
    required this.mobile,
    required this.poTsd,
    required this.lastUpdated,
    required this.isActive,
  }) : selected = false;
}

class _Trainer {
  final String name;
  final TrainerType type;

  _Trainer({
    required this.name,
    required this.type,
  });
}

enum TrainerType { internal, external }

class _CostEntry {
  String particularName;
  int value;
  String attachment;
  String description;

  _CostEntry({
    required this.particularName,
    required this.value,
    required this.attachment,
    required this.description,
  });
}

class _MaterialEntry {
  String product;
  int quantity;

  _MaterialEntry({
    required this.product,
    required this.quantity,
  });
}

class _FilterDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _FilterDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Select date' : _formatDate(value!);

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

DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}
