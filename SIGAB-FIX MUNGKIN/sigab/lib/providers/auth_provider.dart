import 'package:flutter/material.dart';
import '../api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> checkAuthStatus() async {
    final token = await ApiService.getToken();
    _isAuthenticated = token != null;
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }
}
