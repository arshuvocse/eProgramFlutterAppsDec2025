
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database_helper.dart';
import '../model/user_model.dart';
import '../config/api_config.dart';
import '../services/device_info_service.dart';

class LoginViewModel with ChangeNotifier {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final DatabaseHelper _db = DatabaseHelper();

  TextEditingController get usernameController => _usernameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<bool> login() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Username and password are required';
      _loading = false;
      notifyListeners();
      return false;
    }

    try {
      final deviceParams = await _deviceInfoService.getLoginParams();

      final uri = Uri.parse(ApiConfig.login).replace(queryParameters: {
        'UserName': username,
        'password': password,
        'Imei': deviceParams['Imei'] ?? '001',
        'DeviceToken': deviceParams['DeviceToken'] ?? '001',
        'Device': deviceParams['Device'] ?? '001',
        'AppVersion': deviceParams['AppVersion'] ?? '01',
        'OS': deviceParams['OS'] ?? '01',
        'OS_Version': deviceParams['OS_Version'] ?? '01',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        // Try to surface server-provided message if available
        String? serverMsg;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['message'] != null) {
            serverMsg = decoded['message'].toString();
          }
        } catch (_) {
          // ignore decode error, will fall back to generic message
        }
        _errorMessage = serverMsg ?? 'Login failed (${response.statusCode}). Please try again.';
        _loading = false;
        notifyListeners();
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        _errorMessage = 'Unexpected response from server. Please try again.';
        _loading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> data = decoded;
      final twoDeviceMsg = (data['twoDeviceMsg'] ?? '').toString().trim();
      if (twoDeviceMsg.isNotEmpty) {
        _errorMessage = twoDeviceMsg;
        _loading = false;
        notifyListeners();
        return false;
      }

      final userIdRaw = data['userId'];
      final userId = userIdRaw is int ? userIdRaw : int.tryParse('$userIdRaw') ?? 0;

      if (userId == 0) {
        final loginMessage = (data['loginMessage'] ?? '').toString().trim();
        final msg = (data['message'] ?? 'Invalid username or password').toString().trim();
        _errorMessage = loginMessage.isNotEmpty
            ? loginMessage
            : (msg.isNotEmpty ? msg : 'Invalid username or password');
        _loading = false;
        notifyListeners();
        return false;
      }

      final user = User.fromJson({
        ...data,
        // Override with submitted password (API may echo empty string)
        'password': password,
        'userEmail': data['userEmail'] ?? data['email'] ?? '',
      });

      await _db.saveUser(user);
      _errorMessage = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Unable to login. Please check your connection and try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
