import 'package:flutter/foundation.dart';

import '../data/repository.dart';
import '../model/provider_model.dart';

class ProvidersViewModel extends ChangeNotifier {
  final DataRepository _repo = DataRepository();

  List<ProviderModel> _all = const [];

  String _chip = 'All';
  String _query = '';

  String get chip => _chip;
  String get query => _query;

  List<ProviderModel> get providers {
    final q = _query.toLowerCase();
    return _all.where((p) {
      final okChip = _chip == 'All' ? true : p.category == _chip;
      final okQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return okChip && okQuery;
    }).toList();
  }

  Future<void> init() async {
    await _repo.seedProvidersIfEmpty();
    _all = await _repo.getProviders();
    notifyListeners();
  }

  void setChip(String value) {
    _chip = value;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    _all = await _repo.getProviders();
    notifyListeners();
  }
}
