import 'package:flutter/material.dart';

class AccountModel extends ChangeNotifier {
  bool isLoading = false;

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
