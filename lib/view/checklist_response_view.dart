import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

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
  bool _loading = false;
  bool _hasSearched = false;
  String? _error;
  List<_ChecklistSubmission> _results = const [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _fromDate = today;
    _toDate = today;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
    });
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
                onPressed: _loading ? null : _search,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_loading ? 'Searching' : 'Search'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Provider Submissions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _dashboardSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              child: _buildResults(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          _hasSearched
              ? 'No submissions found.'
              : 'Select a date range to search.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _results[index];
        return _SubmissionCard(
          data: item,
          onTap: () => _openDetails(item),
        );
      },
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

  Future<void> _search() async {
    if (_loading) return;

    var fromDate = _fromDate;
    var toDate = _toDate;

    if (fromDate == null && toDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range.')),
      );
      return;
    }

    if (fromDate == null || toDate == null) {
      final fallback = fromDate ?? toDate!;
      setState(() {
        _fromDate = fallback;
        _toDate = fallback;
      });
      fromDate = fallback;
      toDate = fallback;
    }

    if (fromDate.isAfter(toDate)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From date cannot be after To date.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _hasSearched = true;
      _error = null;
    });

    try {
      final list = await _fetchSubmissions(fromDate, toDate);
      if (!mounted) return;
      setState(() {
        _results = list;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _error = 'Unable to load checklist responses. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<List<_ChecklistSubmission>> _fetchSubmissions(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final uri = Uri.parse(ApiConfig.checklistSubmissionWithAnswers).replace(
      queryParameters: {
        'fromDate': _formatApiDate(fromDate),
        'toDate': _formatApiDate(toDate),
      },
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Fetch failed (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected response');
    }

    final list = decoded
        .whereType<Map<String, dynamic>>()
        .map(_ChecklistSubmission.fromMap)
        .toList();

    list.sort((a, b) {
      final ad = a.submittedAt;
      final bd = b.submittedAt;
      if (ad == null && bd == null) {
        return b.submissionId.compareTo(a.submissionId);
      }
      if (ad == null) return 1;
      if (bd == null) return -1;
      final c = bd.compareTo(ad);
      if (c != 0) return c;
      return b.submissionId.compareTo(a.submissionId);
    });

    return list;
  }

  void _openDetails(_ChecklistSubmission submission) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubmissionDetailsSheet(submission: submission),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final _ChecklistSubmission data;
  final VoidCallback onTap;

  const _SubmissionCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final submittedAt = data.submittedAt;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.providerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusChip(isDraft: data.isDraft),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Code: ${data.providerCode}',
                style: const TextStyle(color: Colors.black54),
              ),
              if (data.mobileNo.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Mobile: ${data.mobileNo}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              if (data.programShortName.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Program: ${data.programShortName}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Checklist: ${data.setName} (${data.setCode})',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaChip(
                    icon: Icons.list_alt_outlined,
                    label: '${data.details.length} answers',
                  ),
                  if (submittedAt != null)
                    _MetaChip(
                      icon: Icons.schedule,
                      label: _formatDateTime(context, submittedAt),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmissionDetailsSheet extends StatelessWidget {
  final _ChecklistSubmission submission;

  const _SubmissionDetailsSheet({required this.submission});

  @override
  Widget build(BuildContext context) {
    final submittedAt = submission.submittedAt;
    final details = submission.details;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          minChildSize: 0.5,
          maxChildSize: 0.98,
          builder: (context, controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Submission Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _dashboardSecondary,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.providerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Code: ${submission.providerCode}'),
                      if (submission.mobileNo.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Mobile: ${submission.mobileNo}'),
                      ],
                      if (submission.programShortName.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Program: ${submission.programShortName}'),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Checklist: ${submission.setName} (${submission.setCode})',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _StatusChip(isDraft: submission.isDraft),
                          _MetaChip(
                            icon: Icons.list_alt_outlined,
                            label: '${details.length} answers',
                          ),
                          if (submittedAt != null)
                            _MetaChip(
                              icon: Icons.schedule,
                              label: _formatDateTime(context, submittedAt),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: details.isEmpty
                      ? const Center(
                          child: Text('No answers found for this submission.'),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          itemCount: details.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _AnswerTile(answer: details[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final _ChecklistAnswer answer;

  const _AnswerTile({required this.answer});

  @override
  Widget build(BuildContext context) {
    final createdAt = answer.answerCreatedAt;
    final hasImage = answer.imageLink.trim().isNotEmpty;
    final isValidImage = hasImage && _isValidImageUrl(answer.imageLink);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.questionTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: _dashboardSecondary,
            ),
          ),
          if (answer.questionDescription.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              answer.questionDescription,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: Icons.tune,
                label: answer.displayTypeLabel,
              ),
              if (createdAt != null)
                _MetaChip(
                  icon: Icons.schedule,
                  label: _formatDateTime(context, createdAt),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            answer.displayValue,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 8),
            if (isValidImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  answer.imageLink,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Image not available'),
                  ),
                ),
              )
            else
              Text(
                'Image: ${answer.imageLink}',
                style: const TextStyle(color: Colors.black54),
              ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _dashboardPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _dashboardPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _dashboardPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _dashboardPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isDraft;

  const _StatusChip({required this.isDraft});

  @override
  Widget build(BuildContext context) {
    final color = isDraft ? Colors.orange : _dashboardPrimary;
    final label = isDraft ? 'Draft' : 'Submitted';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ChecklistSubmission {
  final int submissionId;
  final int userId;
  final int programId;
  final int providerId;
  final String providerCode;
  final String providerName;
  final String mobileNo;
  final String programShortName;
  final int assignmentId;
  final int setId;
  final bool isDraft;
  final String setCode;
  final String setName;
  final List<_ChecklistAnswer> details;

  _ChecklistSubmission({
    required this.submissionId,
    required this.userId,
    required this.programId,
    required this.providerId,
    required this.providerCode,
    required this.providerName,
    required this.mobileNo,
    required this.programShortName,
    required this.assignmentId,
    required this.setId,
    required this.isDraft,
    required this.setCode,
    required this.setName,
    required this.details,
  });

  factory _ChecklistSubmission.fromMap(Map<String, dynamic> m) {
    final rawDetails = m['details'];
    final details = (rawDetails is List)
        ? rawDetails
            .whereType<Map<String, dynamic>>()
            .map(_ChecklistAnswer.fromMap)
            .toList()
        : <_ChecklistAnswer>[];

    details.sort((a, b) {
      final c = a.sortOrder.compareTo(b.sortOrder);
      if (c != 0) return c;
      return a.questionTitle.compareTo(b.questionTitle);
    });

    return _ChecklistSubmission(
      submissionId: _asInt(m['submissionId']),
      userId: _asInt(m['userId']),
      programId: _asInt(m['programId']),
      providerId: _asInt(m['providerId']),
      providerCode: (m['providerCode'] ?? '').toString(),
      providerName: (m['providerName'] ?? '').toString(),
      mobileNo: (m['mobileNo'] ?? '').toString(),
      programShortName: (m['programShortName'] ?? '').toString(),
      assignmentId: _asInt(m['assignmentId']),
      setId: _asInt(m['setId']),
      isDraft: _asBool(m['isDraft']),
      setCode: (m['setCode'] ?? '').toString(),
      setName: (m['setName'] ?? '').toString(),
      details: details,
    );
  }

  DateTime? get submittedAt {
    DateTime? latest;
    for (final item in details) {
      final date = item.answerCreatedAt;
      if (date == null) continue;
      if (latest == null || date.isAfter(latest)) {
        latest = date;
      }
    }
    return latest;
  }
}

class _ChecklistAnswer {
  final String answerType;
  final String answerText;
  final List<int> selectedOptionIds;
  final String imageLink;
  final DateTime? answerCreatedAt;
  final int sortOrder;
  final String questionTitle;
  final String questionDescription;

  _ChecklistAnswer({
    required this.answerType,
    required this.answerText,
    required this.selectedOptionIds,
    required this.imageLink,
    required this.answerCreatedAt,
    required this.sortOrder,
    required this.questionTitle,
    required this.questionDescription,
  });

  factory _ChecklistAnswer.fromMap(Map<String, dynamic> m) {
    return _ChecklistAnswer(
      answerType: (m['answerType'] ?? '').toString(),
      answerText: (m['answerText'] ?? '').toString(),
      selectedOptionIds: _parseIdList(m['selectedOptionIdsJson']),
      imageLink: (m['imageLink'] ?? '').toString(),
      answerCreatedAt: _parseDate(m['answerCreatedAt']),
      sortOrder: _asInt(m['sortOrder']),
      questionTitle: (m['questionTitle'] ?? '').toString(),
      questionDescription: (m['questionDescription'] ?? '').toString(),
    );
  }

  String get displayTypeLabel {
    final type = answerType.trim().toLowerCase();
    switch (type) {
      case 'checkbox':
        return 'Checkbox';
      case 'radiobutton':
        return 'Radio';
      case 'textbox':
        return 'Text';
      case 'textarea':
        return 'Text Area';
      case 'rating':
        return 'Rating';
      case 'image':
        return 'Image';
      default:
        return type.isEmpty ? 'Answer' : type;
    }
  }

  String get displayValue {
    final text = answerText.trim();
    if (text.isNotEmpty) return text;
    if (selectedOptionIds.isNotEmpty) {
      return 'Selected: ${selectedOptionIds.join(', ')}';
    }
    if (imageLink.trim().isNotEmpty) return 'Image attached';
    return 'No answer provided';
  }
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

String _formatApiDate(DateTime date) {
  const months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  return '$day-$month-${date.year}';
}

String _formatDateTime(BuildContext context, DateTime dateTime) {
  final local = dateTime.toLocal();
  final date = MaterialLocalizations.of(context).formatMediumDate(local);
  final time = MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
  );
  return '$date $time';
}

List<int> _parseIdList(dynamic raw) {
  final value = (raw ?? '').toString().trim();
  if (value.isEmpty) return const [];
  try {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    }
  } catch (_) {}
  return const [];
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

bool _isValidImageUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}

int _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final str = (v ?? '').toString().toLowerCase();
  return str == 'true' || str == '1';
}
