import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../model/provider_model.dart';
import '../utils/app_snackbar.dart';
import '../viewmodel/checklist_viewmodel.dart';

class ChecklistView extends StatelessWidget {
  final ProviderModel provider;
  const ChecklistView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF008080);
    return ChangeNotifierProvider(
      create: (_) => ChecklistViewModel(provider: provider)..init(),
      child: Consumer<ChecklistViewModel>(
        builder: (context, vm, _) {
          final actionBusy = vm.isActionBusy;
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FB),
            appBar: AppBar(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              title: const Text('Checklist'),
            ),
            body: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : _ChecklistBody(brand: brand, vm: vm, provider: provider),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: brand,
                            side: BorderSide(
                              color: brand.withValues(alpha: 0.6),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: vm.hasAnyAnswer && !actionBusy
                              ? () async {
                                  final result = await vm.saveDraft();
                                  if (!context.mounted) return;
                                  if (result.isSuccess) {
                                    AppSnackBar.show(
                                      context,
                                      'Draft saved successfully.',
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    AppSnackBar.show(
                                      context,
                                      result.message,
                                      tone: SnackTone.error,
                                    );
                                  }
                                }
                              : null,
                          child: vm.isDrafting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: brand,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Saving Draft'),
                                  ],
                                )
                              : const Text('Draft'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: vm.isComplete && !actionBusy
                              ? () async {
                                  final result = await vm.submit();
                                  if (!context.mounted) return;
                                  if (result.isSuccess) {
                                    AppSnackBar.show(
                                      context,
                                      'Checklist submitted successfully.',
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    AppSnackBar.show(
                                      context,
                                      result.message,
                                      tone: SnackTone.error,
                                    );
                                  }
                                }
                              : null,
                          child: vm.isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Submitting'),
                                  ],
                                )
                              : const Text('Submit Checklist'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChecklistBody extends StatelessWidget {
  final Color brand;
  final ChecklistViewModel vm;
  final ProviderModel provider;
  const _ChecklistBody({
    required this.brand,
    required this.vm,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: vm.init,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          _ProviderCard(provider: provider, brand: brand),
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.error!,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (vm.assignments.isNotEmpty) ...[
            const Text(
              'Select Checklist',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Column(
                children: [
                  for (final a in vm.assignments)
                    RadioListTile<int>(
                      value: a.setId,
                      groupValue: vm.selectedSetId,
                      onChanged: (v) {
                        if (v != null) vm.selectAssignment(v);
                      },
                      activeColor: brand,
                      title: Text(a.setName),
                      subtitle: Text(a.setCode),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (vm.selectedSetId == null)
            const Center(child: Text('No checklist available'))
          else
            _QuestionsCard(vm: vm, brand: brand),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final Color brand;
  const _ProviderCard({required this.provider, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.providerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('Code: ${provider.providerCode}'),
            const SizedBox(height: 4),
            Text(
              provider.mobileNo.isNotEmpty ? provider.mobileNo : provider.email,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.programName,
                style: TextStyle(color: brand, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionsCard extends StatelessWidget {
  final ChecklistViewModel vm;
  final Color brand;
  const _QuestionsCard({required this.vm, required this.brand});

  @override
  Widget build(BuildContext context) {
    final questions = vm.questions;
    if (questions.isEmpty) {
      return const Center(
        child: Text('No questions found for this checklist.'),
      );
    }

    final setName = vm.assignments
        .firstWhere(
          (a) => a.setId == vm.selectedSetId,
          orElse: () => vm.assignments.first,
        )
        .setName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Checklist',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        setName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: brand,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: brand.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '${questions.length} Q',
                    style: TextStyle(color: brand, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < questions.length; i++) ...[
          _QuestionTile(index: i, question: questions[i], vm: vm, brand: brand),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final int index;
  final ChecklistQuestion question;
  final ChecklistViewModel vm;
  final Color brand;

  const _QuestionTile({
    required this.index,
    required this.question,
    required this.vm,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final type = question.answerGroupType.trim().toLowerCase();
    final isMulti = type == 'checkbox' || type == 'multi';
    final meta = _QuestionTypeMeta.fromType(type: type, isMulti: isMulti);
    final helper = _QuestionTypeMeta.helperText(type: type, isMulti: isMulti);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(width: 4, color: brand),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuestionNumberBadge(number: index + 1, brand: brand),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            question.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.25,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _QuestionTypeChip(meta: meta, brand: brand),
                      ],
                    ),
                    if (question.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: brand.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: brand.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: brand),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.description,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (helper.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          helper,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (type == 'textbox' || type == 'textarea')
                      TextField(
                        controller: vm.textControllerFor(question.questionId),
                        minLines: type == 'textarea' ? 3 : 1,
                        maxLines: type == 'textarea' ? 6 : 1,
                        keyboardType: type == 'textarea'
                            ? TextInputType.multiline
                            : TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          hintText: type == 'textarea'
                              ? 'Write details...'
                              : 'Write answer...',
                          prefixIcon: Icon(
                            type == 'textarea'
                                ? Icons.notes_outlined
                                : Icons.edit_outlined,
                            color: brand,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: brand.withValues(alpha: 0.8),
                              width: 1.4,
                            ),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      )
                    else if (type == 'rating')
                      _RatingField(question: question, vm: vm, brand: brand)
                    else if (type == 'image')
                      _ImageField(
                        questionId: question.questionId,
                        vm: vm,
                        brand: brand,
                      )
                    else if (question.options.isEmpty)
                      const Text(
                        'No options found for this question.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      Column(
                        children: [
                          for (final opt in question.options) ...[
                            _ChoiceOptionTile(
                              text: opt.text,
                              selected: isMulti
                                  ? vm.isOptionSelected(
                                      question.questionId,
                                      opt.id,
                                    )
                                  : vm.selectedOptionId(question.questionId) ==
                                        opt.id,
                              isMulti: isMulti,
                              brand: brand,
                              onTap: () => vm.toggleOption(
                                question: question,
                                optionId: opt.id,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  final ChecklistQuestion question;
  final ChecklistViewModel vm;
  final Color brand;

  const _RatingField({
    required this.question,
    required this.vm,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final selected = vm.selectedRating(question) ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => vm.setRating(question: question, rating: i),
              icon: Icon(i <= selected ? Icons.star : Icons.star_border),
              color: brand,
            ),
          const Spacer(),
          Text(
            selected > 0 ? '$selected/5' : 'Not rated',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageField extends StatelessWidget {
  final int questionId;
  final ChecklistViewModel vm;
  final Color brand;

  const _ImageField({
    required this.questionId,
    required this.vm,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final path = vm.imagePath(questionId);
    final fileName = path == null || path.trim().isEmpty
        ? null
        : p.basename(path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.image_outlined, color: brand),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName ?? 'No photo selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              if (fileName != null)
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => vm.clearImage(questionId),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: brand,
                  side: BorderSide(color: brand.withValues(alpha: 0.55)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => vm.pickImage(
                  questionId: questionId,
                  source: ImageSource.gallery,
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: brand,
                  side: BorderSide(color: brand.withValues(alpha: 0.55)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => vm.pickImage(
                  questionId: questionId,
                  source: ImageSource.camera,
                ),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceOptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final bool isMulti;
  final Color brand;
  final VoidCallback onTap;

  const _ChoiceOptionTile({
    required this.text,
    required this.selected,
    required this.isMulti,
    required this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? brand.withValues(alpha: 0.08) : Colors.white;
    final border = selected
        ? brand.withValues(alpha: 0.75)
        : Colors.grey.shade200;
    final icon = isMulti
        ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
        : (selected ? Icons.radio_button_checked : Icons.radio_button_off);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? brand : const Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionTypeChip extends StatelessWidget {
  final _QuestionTypeMeta meta;
  final Color brand;

  const _QuestionTypeChip({required this.meta, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: brand.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 16, color: brand),
          const SizedBox(width: 6),
          Text(
            meta.label,
            style: TextStyle(
              color: brand,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionNumberBadge extends StatelessWidget {
  final int number;
  final Color brand;

  const _QuestionNumberBadge({required this.number, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: brand.withValues(alpha: 0.25)),
      ),
      child: Text(
        number.toString(),
        style: TextStyle(
          color: brand,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _QuestionTypeMeta {
  final String label;
  final IconData icon;

  const _QuestionTypeMeta({required this.label, required this.icon});

  static _QuestionTypeMeta fromType({
    required String type,
    required bool isMulti,
  }) {
    switch (type) {
      case 'checkbox':
      case 'multi':
        return const _QuestionTypeMeta(
          label: 'Multi',
          icon: Icons.check_box_outlined,
        );
      case 'radiobutton':
        return const _QuestionTypeMeta(
          label: 'Single',
          icon: Icons.radio_button_checked,
        );
      case 'textbox':
      case 'textarea':
        return const _QuestionTypeMeta(
          label: 'Text',
          icon: Icons.edit_outlined,
        );
      case 'rating':
        return const _QuestionTypeMeta(
          label: 'Rating',
          icon: Icons.star_outline,
        );
      case 'image':
        return const _QuestionTypeMeta(
          label: 'Photo',
          icon: Icons.image_outlined,
        );
      default:
        return _QuestionTypeMeta(
          label: type.isEmpty ? 'Answer' : type,
          icon: isMulti ? Icons.check_box_outlined : Icons.radio_button_checked,
        );
    }
  }

  static String helperText({required String type, required bool isMulti}) {
    switch (type) {
      case 'checkbox':
      case 'multi':
        return 'Select all that apply';
      case 'radiobutton':
        return 'Select one option';
      case 'textbox':
        return 'Write a short answer';
      case 'textarea':
        return 'Write details';
      case 'rating':
        return 'Tap to rate (1–5)';
      case 'image':
        return 'Upload a supporting photo';
      default:
        return isMulti ? 'Select options' : 'Select one';
    }
  }
}
