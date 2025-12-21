import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/database_helper.dart';
import '../utils/app_snackbar.dart';

class LeaveApplyViewModel with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _returnDate;
  bool _submitting = false;
  String? _snackMessage;
  SnackTone _snackTone = SnackTone.success;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateTime? get returnDate => _returnDate;
  bool get submitting => _submitting;
  String? get snackMessage => _snackMessage;
  SnackTone get snackTone => _snackTone;

  int get durationDays {
    if (_startDate == null || _endDate == null) return 0;
    final diff = _dateOnly(_endDate!).difference(_dateOnly(_startDate!)).inDays;
    return diff < 0 ? 0 : diff;
  }

  void setStartDate(DateTime date) {
    _startDate = _dateOnly(date);
    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
      _endDate = _startDate;
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = _dateOnly(date);
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      _startDate = _endDate;
    }
    notifyListeners();
  }

  void setReturnDate(DateTime date) {
    _returnDate = _dateOnly(date);
    notifyListeners();
  }

  void consumeSnackMessage() {
    if (_snackMessage == null) return;
    _snackMessage = null;
    _snackTone = SnackTone.success;
  }

  Future<bool> submit({required bool isDraft}) async {
    if (_submitting) return false;
    final validationError = _validate();
    if (validationError != null) {
      _setSnack(validationError, SnackTone.error);
      return false;
    }

    _submitting = true;
    notifyListeners();

    try {
      final userId = await _db.getUserId();
      if (userId == null || userId <= 0) {
        _setSnack('Please login to submit leave.', SnackTone.error);
        return false;
      }

      final payload = {
        'userId': userId,
        'startDate': _toUtcIso(_startDate!),
        'endDate': _toUtcIso(_endDate!),
        'durationDays': durationDays,
        'reason': reasonController.text.trim(),
        'returnDate': _toUtcIso(_returnDate!),
        'leaveAddress': addressController.text.trim(),
        'emergencyContactNo': emergencyController.text.trim(),
        'comments': commentsController.text.trim(),
        'isDraft': isDraft,
      };

      final res = await http
          .post(
            Uri.parse(ApiConfig.saveLeave),
            headers: const {'Content-Type': 'application/json', 'accept': '*/*'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        _setSnack('Leave submit failed (${res.statusCode}). Please try again.', SnackTone.error);
        return false;
      }

      String? message;
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          message = decoded['message']?.toString();
          final status = decoded['status'];
          if (status is int && status != 200) {
            _setSnack(message ?? 'Leave submit failed.', SnackTone.error);
            return false;
          }
          if (status is String && status != '200') {
            _setSnack(message ?? 'Leave submit failed.', SnackTone.error);
            return false;
          }
        }
      } catch (_) {
        // ignore parse errors
      }

      _setSnack(message ?? (isDraft ? 'Leave saved as draft.' : 'Leave submitted successfully.'),
          SnackTone.success);
      return true;
    } catch (_) {
      _setSnack('Leave submit failed. Please check your connection and try again.', SnackTone.error);
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  String? _validate() {
    if (_startDate == null) return 'Start date is required.';
    if (_endDate == null) return 'End date is required.';
    if (_returnDate == null) return 'Return date is required.';
    if (reasonController.text.trim().isEmpty) return 'Reason is required.';
    if (emergencyController.text.trim().isEmpty) return 'Emergency contact number is required.';
    if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
      return 'End date cannot be before start date.';
    }
    if (_returnDate != null && _endDate != null && _returnDate!.isBefore(_endDate!)) {
      return 'Return date cannot be before end date.';
    }
    return null;
  }

  void _setSnack(String message, SnackTone tone) {
    _snackMessage = message;
    _snackTone = tone;
    notifyListeners();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _toUtcIso(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).toIso8601String();

  @override
  void dispose() {
    reasonController.dispose();
    addressController.dispose();
    emergencyController.dispose();
    commentsController.dispose();
    super.dispose();
  }
}
