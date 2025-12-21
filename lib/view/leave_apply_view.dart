import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_snackbar.dart';
import '../viewmodel/leave_apply_viewmodel.dart';

class LeaveApplyView extends StatelessWidget {
  const LeaveApplyView({super.key});

  static const _primary = Color(0xFF0C6A63);
  static const _fieldFill = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaveApplyViewModel(),
      child: Consumer<LeaveApplyViewModel>(
        builder: (context, vm, _) {
          if (vm.snackMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              AppSnackBar.show(context, vm.snackMessage!, tone: vm.snackTone);
              vm.consumeSnackMessage();
            });
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              title: const Text(
                'Leave Apply',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    _buildDateField(
                      context,
                      label: 'Start Date',
                      required: true,
                      value: vm.startDate,
                      onTap: () => _pickDate(
                        context,
                        initial: vm.startDate,
                        onPicked: vm.setStartDate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      context,
                      label: 'End Date',
                      required: true,
                      value: vm.endDate,
                      onTap: () => _pickDate(
                        context,
                        initial: vm.endDate ?? vm.startDate,
                        first: vm.startDate,
                        onPicked: vm.setEndDate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField(
                      label: 'Duration (Day)',
                      value: vm.startDate != null && vm.endDate != null
                          ? vm.durationDays.toString()
                          : '-----',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: vm.reasonController,
                      label: 'Reason',
                      required: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      context,
                      label: 'Date Of Return to Duty',
                      required: true,
                      value: vm.returnDate,
                      onTap: () => _pickDate(
                        context,
                        initial: vm.returnDate ?? vm.endDate ?? vm.startDate,
                        first: vm.endDate ?? vm.startDate,
                        onPicked: vm.setReturnDate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: vm.addressController,
                      label: 'Leave Address',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: vm.emergencyController,
                      label: 'Emergency Contact No',
                      required: true,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: vm.commentsController,
                      label: 'Comments',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: vm.submitting
                                ? null
                                : () => _handleSubmit(context, vm, isDraft: true),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _primary, width: 1.6),
                              foregroundColor: _primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: vm.submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                                    ),
                                  )
                                : const Text(
                                    'DRAFT',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: vm.submitting
                                ? null
                                : () => _handleSubmit(context, vm, isDraft: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: vm.submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'SUBMIT',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
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

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required bool required,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDecoration(
          label: label,
          required: required,
          suffix: const Icon(Icons.calendar_month_outlined, color: _primary),
        ),
        child: Text(
          value != null ? _formatDate(value) : '-----',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return InputDecorator(
      decoration: _inputDecoration(label: label),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, required: required),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    bool required = false,
    Widget? suffix,
  }) {
    return InputDecoration(
      label: _label(label, required),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: _fieldFill,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blueGrey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
    );
  }

  Widget _label(String text, bool required) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    DateTime? initial,
    DateTime? first,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: first ?? DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$y-$m-$d';
  }

  Future<void> _handleSubmit(
    BuildContext context,
    LeaveApplyViewModel vm, {
    required bool isDraft,
  }) async {
    final ok = await vm.submit(isDraft: isDraft);
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    }
  }
}
