import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _farmName = '';
  bool _isLoading = false;

  String get name => _name;
  String get farmName => _farmName;
  bool get isLoading => _isLoading;

  /// Called when app starts
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    // 🔌 Firebase will come here later
    // For now, nothing to load

    _isLoading = false;
    notifyListeners();
  }

  /// Called when user saves profile
  Future<void> updateProfile({
    required String name,
    required String farmName,
  }) async {
    _isLoading = true;
    notifyListeners();

    // 🔌 Firebase save will come here later

    _name = name;
    _farmName = farmName;

    _isLoading = false;
    notifyListeners();
  }
}
