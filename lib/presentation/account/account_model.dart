import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountModel extends ChangeNotifier {
  bool isLoading = false;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
