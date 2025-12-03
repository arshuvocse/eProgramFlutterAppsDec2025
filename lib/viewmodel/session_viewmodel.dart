import 'package:flutter/material.dart';
import 'package:e_program_apps/data/database_helper.dart';

class SessionViewModel with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkSession() async {
    _isLoggedIn = await _db.hasUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _db.clearUser();
    _isLoggedIn = false;
    notifyListeners();
  }
}

