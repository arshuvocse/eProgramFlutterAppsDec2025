import 'package:flutter/foundation.dart';

class ProviderItem {
  final String id;
  final String name;
  final String code;
  final String orgName;
  final String type;
  bool selected;
  ProviderItem({
    required this.id,
    required this.name,
    required this.code,
    required this.orgName,
    required this.type,
    this.selected = false,
  });
}

class TourPlanViewModel extends ChangeNotifier {
  // Month/Year
  final List<String> months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];
  int monthIndex; // 0..11
  int year;

  // Selected day
  int? selectedDay;

  // Provider list (mock data now)
  List<ProviderItem> _all = [];
  List<ProviderItem> _filtered = [];
  List<ProviderItem> get providers => _filtered;

  String _query = '';

  TourPlanViewModel({DateTime? seed})
      : monthIndex = (seed ?? DateTime.now()).month - 1,
        year = (seed ?? DateTime.now()).year {
    _seedProviders();
    _applyFilter();
  }

  int daysInMonth() {
    final first = DateTime(year, monthIndex + 1, 1);
    final next = DateTime(year, monthIndex + 2, 1);
    return next.difference(first).inDays;
  }

  String get selectedDateIso =>
      (selectedDay == null)
          ? ''
          : '${year.toString().padLeft(4,'0')}-${(monthIndex+1).toString().padLeft(2,'0')}-${selectedDay!.toString().padLeft(2,'0')}';

  // Actions
  void setMonth(int idx) {
    monthIndex = idx;
    selectedDay = null; // reset day on month change
    notifyListeners();
  }

  void setYear(int y) {
    year = y;
    selectedDay = null;
    notifyListeners();
  }

  void pickDay(int d) {
    selectedDay = d;
    notifyListeners();
  }

  void toggleProvider(String id, bool v) {
    final i = _all.indexWhere((e) => e.id == id);
    if (i != -1) {
      _all[i].selected = v;
      _applyFilter();
      notifyListeners();
    }
  }

  void search(String q) {
    _query = q.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  // Replace these with API calls
  Future<bool> saveDraft() async {
    // TODO: call API with (year, monthIndex+1, selectedDay, selected provider IDs)
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  Future<bool> finalSubmit() async {
    // TODO: call API; mark as final
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  // Private
  void _applyFilter() {
    _filtered = _all.where((p) {
      if (_query.isEmpty) return true;
      return p.name.toLowerCase().contains(_query) ||
          p.code.toLowerCase().contains(_query) ||
          p.orgName.toLowerCase().contains(_query);
    }).toList();
  }

  void _seedProviders() {
    _all = [
      ProviderItem(id:'1', name:'Provider 1', code:'123456', orgName:'LMN Corp', type:'Wholesaler'),
      ProviderItem(id:'2', name:'OPQ Pharma', code:'789012', orgName:'OQ Pharma', type:'Retailer'),
      ProviderItem(id:'3', name:'RST Medical', code:'345678', orgName:'RST Medical', type:'Retailer'),
      ProviderItem(id:'4', name:'UVW Distributors', code:'901234', orgName:'UVW Distribts', type:'Wholesaler'),
    ];
  }
}
