import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';

class NavigationModel extends ChangeNotifier {
  int currentIndex = 0;
  final _auth = FirebaseAuth.instance;
  final _userRepo = UserRepository();
  final logger = Logger();

  Future<void> init() async {
    // 匿名ユーザー作成
    if (_auth.currentUser == null) {
      final credential = await _auth.signInAnonymously();
      final userId = credential.user!.uid;
      await _userRepo.createUser(userId);
    }
    logger.i('AuthUser: ${_auth.currentUser?.uid}');
  }

  void onTabTapped(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
