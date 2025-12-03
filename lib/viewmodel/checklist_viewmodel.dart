import 'package:flutter/foundation.dart';

import '../model/provider_model.dart';
import '../data/repository.dart';

class ChecklistQuestion {
  final int id;
  final String text;
  final List<String> options;
  String? answer;

  ChecklistQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.answer,
  });
}

class ChecklistViewModel extends ChangeNotifier {
  final ProviderModel provider;
  final DataRepository _repo = DataRepository();
  final List<ChecklistQuestion> questions = [
    ChecklistQuestion(
      id: 1,
      text:
          'Status of GSP Signboard (If not visible please request the provider)',
      options: [
        'Not available',
        'Hanged but usable',
        'Hanged but need to be replaced',
        'Available and usable',
      ],
    ),
    ChecklistQuestion(
      id: 2,
      text: 'Do you have MoniBiscuit?',
      options: ['Yes', 'No'],
    ),
    ChecklistQuestion(
      id: 3,
      text: 'Availability and usage of Sharp Box',
      options: ['Not submitted', 'Not updated', 'Submitted and updated'],
    ),
    ChecklistQuestion(
      id: 4,
      text:
          'Has the provider submitted monthly Performance report through Green Star ERS?',
      options: ['Yes', 'Not submitted'],
    ),
    ChecklistQuestion(
      id: 5,
      text: 'Is there any provision for maintaining privacy?',
      options: ['Fully separated room', 'Separate space'],
    ),
  ];

  ChecklistViewModel({required this.provider});

  void setAnswer(int id, String? value) {
    final q = questions.firstWhere((e) => e.id == id);
    q.answer = value;
    notifyListeners();
  }

  bool get isComplete => questions.every((q) => q.answer != null);

  Future<void> submit() async {
    final Map<int, String> answers = {
      for (final q in questions)
        if (q.answer != null) q.id: q.answer!,
    };
    await _repo.saveChecklist(providerCode: provider.code, answers: answers);
  }
}
