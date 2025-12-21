import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import '../data/database_helper.dart';
import '../data/repository.dart';
import '../model/provider_model.dart';

enum _ChecklistAction { submit, draft }

class ChecklistAssignment {
  final int assignmentId;
  final int programId;
  final int setId;
  final String setCode;
  final String setName;

  ChecklistAssignment({
    required this.assignmentId,
    required this.programId,
    required this.setId,
    required this.setCode,
    required this.setName,
  });

  factory ChecklistAssignment.fromMap(Map<String, dynamic> m) =>
      ChecklistAssignment(
        assignmentId: _asInt(m['assignmentId']),
        programId: _asInt(m['programId']),
        setId: _asInt(m['setId']),
        setCode: (m['setCode'] ?? '').toString(),
        setName: (m['setName'] ?? '').toString(),
      );
}

class ChecklistOption {
  final int id;
  final int questionId;
  final String text;
  final int sortOrder;
  final bool active;

  ChecklistOption({
    required this.id,
    required this.questionId,
    required this.text,
    required this.sortOrder,
    required this.active,
  });

  factory ChecklistOption.fromMap(Map<String, dynamic> m) => ChecklistOption(
    id: _asInt(m['questionOptionId']),
    questionId: _asInt(m['questionId']),
    text: (m['optionText'] ?? '').toString(),
    sortOrder: _asInt(m['sortOrder']),
    active: _asBool(m['optionIsActive']),
  );
}

class ChecklistQuestion {
  final int setQuestionId;
  final int setId;
  final int questionId;
  final int sortOrder;
  final String title;
  final String description;
  final String answerGroupType; // RadioButton / CheckBox
  final bool active;
  final List<ChecklistOption> options;

  ChecklistQuestion({
    required this.setQuestionId,
    required this.setId,
    required this.questionId,
    required this.sortOrder,
    required this.title,
    required this.description,
    required this.answerGroupType,
    required this.active,
    required this.options,
  });

  ChecklistQuestion copyWith({List<ChecklistOption>? options}) {
    return ChecklistQuestion(
      setQuestionId: setQuestionId,
      setId: setId,
      questionId: questionId,
      sortOrder: sortOrder,
      title: title,
      description: description,
      answerGroupType: answerGroupType,
      active: active,
      options: options ?? this.options,
    );
  }

  factory ChecklistQuestion.fromMap(Map<String, dynamic> m) =>
      ChecklistQuestion(
        setQuestionId: _asInt(m['setQuestionId']),
        setId: _asInt(m['setId']),
        questionId: _asInt(m['questionId']),
        sortOrder: _asInt(m['sortOrder']),
        title: (m['questionTitle'] ?? '').toString(),
        description: (m['questionDescription'] ?? '').toString(),
        answerGroupType: (m['answerGroupType'] ?? '').toString(),
        active: _asBool(m['questionIsActive']),
        options: const [],
      );
}

class ChecklistViewModel extends ChangeNotifier {
  final ProviderModel provider;
  final DataRepository _repo = DataRepository();
  final DatabaseHelper _db = DatabaseHelper();
  final ImagePicker _imagePicker = ImagePicker();

  bool _loading = false;
  String? _error;
  int? _selectedSetId;
  int? _userId;
  _ChecklistAction? _actionInProgress;

  List<ChecklistAssignment> _assignments = const [];
  List<ChecklistQuestion> _questions = const [];
  final Map<int, Set<int>> _optionAnswers = {};
  final Map<int, String> _textAnswers = {};
  final Map<int, String> _imageAnswers = {};
  final Map<int, TextEditingController> _textControllers = {};

  ChecklistViewModel({required this.provider});

  bool get loading => _loading;
  String? get error => _error;
  List<ChecklistAssignment> get assignments => _assignments;
  int? get selectedSetId => _selectedSetId;
  bool get isSubmitting => _actionInProgress == _ChecklistAction.submit;
  bool get isDrafting => _actionInProgress == _ChecklistAction.draft;
  bool get isActionBusy => _actionInProgress != null;

  List<ChecklistQuestion> get questions {
    return _questions
        .where((q) => q.active && q.setId == _selectedSetId)
        .toList()
      ..sort((a, b) {
        final c = a.sortOrder.compareTo(b.sortOrder);
        if (c != 0) return c;
        return a.questionId.compareTo(b.questionId);
      });
  }

  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final userId = await _db.getUserId();
    _userId = userId;
    if (userId == null || userId <= 0) {
      _error = 'Please login to load checklist.';
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final payload = await _fetchAssignments(
        userId: userId,
        programId: provider.programId,
      );
      _assignments = payload.assignments;
      _selectedSetId = _assignments.isNotEmpty
          ? _assignments.first.setId
          : null;
      _questions = payload.questions;
      _pruneAnswerCache();
      _error = null;
    } catch (e) {
      _error = 'Unable to load checklist. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<_ChecklistPayload> _fetchAssignments({
    required int userId,
    required int programId,
  }) async {
    final uri = Uri.parse(ApiConfig.checklistAssignments).replace(
      queryParameters: {
        'userId': userId.toString(),
        'ProgramId': programId.toString(),
      },
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected checklist response');
    }

    final assignmentsRaw = decoded['assignments'];
    final questionsRaw = decoded['questions'];
    final optionsRaw = decoded['options'];

    final assignments = (assignmentsRaw is List)
        ? assignmentsRaw
              .whereType<Map<String, dynamic>>()
              .map(ChecklistAssignment.fromMap)
              .toList()
        : <ChecklistAssignment>[];

    final options = (optionsRaw is List)
        ? optionsRaw
              .whereType<Map<String, dynamic>>()
              .map(ChecklistOption.fromMap)
              .where((o) => o.active)
              .toList()
        : <ChecklistOption>[];

    final optionMap = <int, List<ChecklistOption>>{};
    for (final o in options) {
      optionMap.putIfAbsent(o.questionId, () => []).add(o);
    }
    for (final list in optionMap.values) {
      list.sort((a, b) {
        final c = a.sortOrder.compareTo(b.sortOrder);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });
    }

    final questions = (questionsRaw is List)
        ? questionsRaw
              .whereType<Map<String, dynamic>>()
              .map(ChecklistQuestion.fromMap)
              .map((q) {
                final opts =
                    optionMap[q.questionId] ?? const <ChecklistOption>[];
                return q.copyWith(options: opts);
              })
              .toList()
        : <ChecklistQuestion>[];

    questions.sort((a, b) {
      final c = a.sortOrder.compareTo(b.sortOrder);
      if (c != 0) return c;
      return a.questionId.compareTo(b.questionId);
    });
    return _ChecklistPayload(assignments: assignments, questions: questions);
  }

  void selectAssignment(int setId) {
    _selectedSetId = setId;
    notifyListeners();
  }

  void _setAction(_ChecklistAction? action) {
    if (_actionInProgress == action) return;
    _actionInProgress = action;
    notifyListeners();
  }

  ChecklistAssignment? get _currentAssignment {
    final setId = _selectedSetId;
    if (setId == null) return null;
    for (final a in _assignments) {
      if (a.setId == setId) return a;
    }
    return null;
  }

  String _typeOf(ChecklistQuestion q) => q.answerGroupType.trim().toLowerCase();

  bool _isMulti(ChecklistQuestion q) =>
      q.answerGroupType.toLowerCase() == 'checkbox' ||
      q.answerGroupType.toLowerCase() == 'multi';

  int? selectedOptionId(int questionId) {
    final set = _optionAnswers[questionId];
    if (set == null || set.isEmpty) return null;
    return set.first;
  }

  bool isOptionSelected(int questionId, int optionId) {
    return _optionAnswers[questionId]?.contains(optionId) ?? false;
  }

  void toggleOption({
    required ChecklistQuestion question,
    required int optionId,
  }) {
    final isMulti = _isMulti(question);
    final current = _optionAnswers[question.questionId] ?? <int>{};
    final next = <int>{...current};

    if (isMulti) {
      if (next.contains(optionId)) {
        next.remove(optionId);
      } else {
        next.add(optionId);
      }
    } else {
      next
        ..clear()
        ..add(optionId);
    }

    _optionAnswers[question.questionId] = next;
    notifyListeners();
  }

  TextEditingController textControllerFor(int questionId) {
    final existing = _textControllers[questionId];
    if (existing != null) return existing;

    final controller = TextEditingController(
      text: _textAnswers[questionId] ?? '',
    );
    controller.addListener(() {
      final next = controller.text;
      if (_textAnswers[questionId] == next) return;
      _textAnswers[questionId] = next;
      notifyListeners();
    });
    _textControllers[questionId] = controller;
    return controller;
  }

  String textAnswer(int questionId) => _textAnswers[questionId] ?? '';

  void setTextAnswer({required int questionId, required String value}) {
    if (_textAnswers[questionId] == value) return;
    _textAnswers[questionId] = value;
    final controller = _textControllers[questionId];
    if (controller != null && controller.text != value) {
      controller.text = value;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
    notifyListeners();
  }

  int? selectedRating(ChecklistQuestion question) {
    final type = _typeOf(question);
    if (type != 'rating') return null;

    if (question.options.isNotEmpty) {
      final selectedId = selectedOptionId(question.questionId);
      if (selectedId == null) return null;
      final opt = question.options.where((o) => o.id == selectedId).firstOrNull;
      if (opt == null) return null;
      return int.tryParse(opt.text) ?? opt.sortOrder;
    }

    return int.tryParse(textAnswer(question.questionId));
  }

  void setRating({required ChecklistQuestion question, required int rating}) {
    final type = _typeOf(question);
    if (type != 'rating') return;

    final match = question.options
        .where((o) => o.text.trim() == rating.toString())
        .firstOrNull;
    if (match != null) {
      toggleOption(question: question, optionId: match.id);
      return;
    }
    setTextAnswer(questionId: question.questionId, value: rating.toString());
  }

  String? imagePath(int questionId) => _imageAnswers[questionId];

  void clearImage(int questionId) {
    if (!_imageAnswers.containsKey(questionId)) return;
    _imageAnswers.remove(questionId);
    notifyListeners();
  }

  Future<void> pickImage({
    required int questionId,
    required ImageSource source,
  }) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return;
      _imageAnswers[questionId] = file.path;
      notifyListeners();
    } catch (_) {
      // Keep silent; UI can show a generic error if needed.
    }
  }

  bool get isComplete {
    final qs = questions;
    if (qs.isEmpty) return false;
    return qs.every((q) {
      final type = _typeOf(q);
      if (type == 'textbox' || type == 'textarea') {
        return (_textAnswers[q.questionId]?.trim().isNotEmpty ?? false);
      }
      if (type == 'image') {
        return (_imageAnswers[q.questionId]?.trim().isNotEmpty ?? false);
      }
      if (type == 'rating' && q.options.isEmpty) {
        return (_textAnswers[q.questionId]?.trim().isNotEmpty ?? false);
      }
      // Default: option-based
      return (_optionAnswers[q.questionId]?.isNotEmpty ?? false);
    });
  }

  bool get hasAnyAnswer {
    final qs = questions;
    if (qs.isEmpty) return false;
    for (final q in qs) {
      final type = _typeOf(q);
      if (type == 'textbox' || type == 'textarea') {
        if ((_textAnswers[q.questionId]?.trim().isNotEmpty ?? false)) {
          return true;
        }
        continue;
      }
      if (type == 'image') {
        if ((_imageAnswers[q.questionId]?.trim().isNotEmpty ?? false)) {
          return true;
        }
        continue;
      }
      if (type == 'rating' && q.options.isEmpty) {
        if ((_textAnswers[q.questionId]?.trim().isNotEmpty ?? false)) {
          return true;
        }
        continue;
      }
      if ((_optionAnswers[q.questionId]?.isNotEmpty ?? false)) {
        return true;
      }
    }
    return false;
  }

  Future<ChecklistSubmitResult> submit() async {
    if (isActionBusy) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Another action is in progress. Please wait.',
      );
    }
    if (!isComplete) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Please complete all questions before submitting.',
      );
    }

    final assignment = _currentAssignment;
    if (assignment == null) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Please select a checklist before submitting.',
      );
    }

    final userId = _userId ?? await _db.getUserId();
    if (userId == null || userId <= 0) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Please login to submit the checklist.',
      );
    }
    _userId = userId;

    _setAction(_ChecklistAction.submit);
    try {
      final answers = await _buildAnswerPayloads();
      if (answers.isEmpty) {
        return const ChecklistSubmitResult(
          isSuccess: false,
          message: 'No answers found to submit.',
        );
      }

      final payload = _buildSubmitPayload(
        assignment: assignment,
        userId: userId,
        isDraft: false,
        answers: answers,
      );

      final result = await _submitChecklist(payload);
      if (result.isSuccess) {
        final answerMap = _buildAnswerMap();
        if (answerMap.isNotEmpty) {
          await _repo.saveChecklist(
            providerCode: provider.providerCode,
            providerId: provider.providerId,
            answers: answerMap,
            isDraft: false,
          );
        }
      }
      return result;
    } finally {
      _setAction(null);
    }
  }

  Future<ChecklistSubmitResult> saveDraft() async {
    if (isActionBusy) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Another action is in progress. Please wait.',
      );
    }
    if (!hasAnyAnswer) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Add at least one answer to save a draft.',
      );
    }

    final assignment = _currentAssignment;
    if (assignment == null) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Please select a checklist before saving.',
      );
    }

    final userId = _userId ?? await _db.getUserId();
    if (userId == null || userId <= 0) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Please login to save the draft.',
      );
    }
    _userId = userId;

    _setAction(_ChecklistAction.draft);
    try {
      final answers = await _buildAnswerPayloads();
      if (answers.isEmpty) {
        return const ChecklistSubmitResult(
          isSuccess: false,
          message: 'No answers found to save.',
        );
      }

      final payload = _buildSubmitPayload(
        assignment: assignment,
        userId: userId,
        isDraft: true,
        answers: answers,
      );

      final result = await _submitChecklist(payload);
      if (result.isSuccess) {
        final answerMap = _buildAnswerMap();
        if (answerMap.isNotEmpty) {
          await _repo.saveChecklist(
            providerCode: provider.providerCode,
            providerId: provider.providerId,
            answers: answerMap,
            isDraft: true,
          );
        }
      }
      return result;
    } finally {
      _setAction(null);
    }
  }

  Map<String, dynamic> _buildSubmitPayload({
    required ChecklistAssignment assignment,
    required int userId,
    required bool isDraft,
    required List<Map<String, dynamic>> answers,
  }) {
    return {
      'userId': userId,
      'programId':
          assignment.programId > 0 ? assignment.programId : provider.programId,
      'providerId': provider.providerId,
      'providerCode': provider.providerCode,
      'assignmentId': assignment.assignmentId,
      'setId': assignment.setId,
      'isDraft': isDraft,
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
      'answers': answers,
    };
  }

  Future<List<Map<String, dynamic>>> _buildAnswerPayloads() async {
    final results = <Map<String, dynamic>>[];
    final qs = questions;
    for (final q in qs) {
      final type = _typeOf(q);
      final answerType = q.answerGroupType;
      List<int> selectedOptionIds = const [];
      var answerText = '';
      var imageBase64 = '';

      if (type == 'textbox' || type == 'textarea') {
        answerText = (_textAnswers[q.questionId] ?? '').trim();
        if (answerText.isEmpty) continue;
      } else if (type == 'image') {
        final path = (_imageAnswers[q.questionId] ?? '').trim();
        if (path.isEmpty) continue;
        imageBase64 = await _encodeImageBase64(path);
        if (imageBase64.isEmpty) continue;
      } else if (type == 'rating' && q.options.isEmpty) {
        answerText = (_textAnswers[q.questionId] ?? '').trim();
        if (answerText.isEmpty) continue;
      } else {
        final selected = _optionAnswers[q.questionId] ?? <int>{};
        if (selected.isEmpty) continue;
        selectedOptionIds = selected.toList()..sort();
        final optionTexts = q.options
            .where((o) => selected.contains(o.id))
            .map((o) => o.text)
            .where((t) => t.trim().isNotEmpty)
            .toList();
        if (optionTexts.isNotEmpty) {
          answerText = optionTexts.join(', ');
        }
      }

      results.add({
        'questionId': q.questionId,
        'setQuestionId': q.setQuestionId,
        'answerType': answerType,
        'selectedOptionIds': selectedOptionIds,
        'answerText': answerText,
        'imageBase64': imageBase64,
      });
    }
    return results;
  }

  Future<String> _encodeImageBase64(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return '';
    }
  }

  Future<ChecklistSubmitResult> _submitChecklist(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConfig.saveChecklist),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return ChecklistSubmitResult(
          isSuccess: false,
          message: 'Submit failed (${res.statusCode}).',
        );
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final ok = decoded['isSuccess'];
        final message =
            (decoded['message'] ?? decoded['errorMessage'] ?? 'Submit failed')
                .toString();
        if (ok is bool) {
          return ChecklistSubmitResult(isSuccess: ok, message: message);
        }
      }
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Unexpected response from server.',
      );
    } catch (_) {
      return const ChecklistSubmitResult(
        isSuccess: false,
        message: 'Submit failed. Please try again.',
      );
    }
  }

  Map<int, String> _buildAnswerMap() {
    final answerMap = <int, String>{};
    final qs = questions;
    for (final q in qs) {
      final type = _typeOf(q);
      if (type == 'textbox' || type == 'textarea') {
        final value = (_textAnswers[q.questionId] ?? '').trim();
        if (value.isNotEmpty) {
          answerMap[q.questionId] = value;
        }
        continue;
      }
      if (type == 'image') {
        final value = (_imageAnswers[q.questionId] ?? '').trim();
        if (value.isNotEmpty) {
          answerMap[q.questionId] = value;
        }
        continue;
      }
      if (type == 'rating' && q.options.isEmpty) {
        final value = (_textAnswers[q.questionId] ?? '').trim();
        if (value.isNotEmpty) {
          answerMap[q.questionId] = value;
        }
        continue;
      }

      final selected = _optionAnswers[q.questionId];
      if (selected == null || selected.isEmpty) continue;
      final optionTexts = q.options
          .where((o) => selected.contains(o.id))
          .map((o) => o.text)
          .where((t) => t.trim().isNotEmpty)
          .toList();
      if (optionTexts.isNotEmpty) {
        answerMap[q.questionId] = optionTexts.join(', ');
      }
    }
    return answerMap;
  }

  void _pruneAnswerCache() {
    final ids = _questions.map((q) => q.questionId).toSet();
    _optionAnswers.removeWhere((k, _) => !ids.contains(k));
    _textAnswers.removeWhere((k, _) => !ids.contains(k));
    _imageAnswers.removeWhere((k, _) => !ids.contains(k));

    final textIds = _questions
        .where((q) {
          final t = _typeOf(q);
          return t == 'textbox' || t == 'textarea';
        })
        .map((q) => q.questionId)
        .toSet();

    final toDispose = _textControllers.keys
        .where((k) => !textIds.contains(k))
        .toList();
    for (final k in toDispose) {
      _textControllers[k]?.dispose();
      _textControllers.remove(k);
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }
}

class _ChecklistPayload {
  final List<ChecklistAssignment> assignments;
  final List<ChecklistQuestion> questions;

  _ChecklistPayload({required this.assignments, required this.questions});
}

class ChecklistSubmitResult {
  final bool isSuccess;
  final String message;

  const ChecklistSubmitResult({required this.isSuccess, required this.message});
}

int _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final str = (v ?? '').toString().toLowerCase();
  return str == 'true' || str == '1';
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
