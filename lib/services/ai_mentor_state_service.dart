import 'package:flutter/material.dart';

class AIMentorStateService extends ChangeNotifier {
  static final AIMentorStateService _instance =
      AIMentorStateService._internal();
  factory AIMentorStateService() => _instance;
  AIMentorStateService._internal();

  bool _isAIMentorOpen = false;

  bool get isAIMentorOpen => _isAIMentorOpen;

  void setAIMentorOpen(bool isOpen) {
    if (_isAIMentorOpen != isOpen) {
      _isAIMentorOpen = isOpen;
      notifyListeners();
    }
  }
}



