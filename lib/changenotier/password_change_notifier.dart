import 'package:flutter/material.dart';

class PasswordVisibilityProvider with ChangeNotifier {
  bool _isObsureText = true;

  bool get isObsureText => _isObsureText;

  void toggleVisibility() {
    _isObsureText = !_isObsureText;
    notifyListeners();
  }
}
