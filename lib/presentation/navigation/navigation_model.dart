import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:stripe_platform_example/repository/stripe_repository.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';

class NavigationModel extends ChangeNotifier {
  int currentIndex = 0;
  final _auth = FirebaseAuth.instance;
  final _userRepo = UserRepository();
  final _stripeRepo = StripeRepository();
  final logger = Logger();

  Future<void> init() async {
    // 新規ユーザー作成
    if (_auth.currentUser == null) {
      // 匿名ログイン
      final credential = await _auth.signInAnonymously();
      final userId = credential.user!.uid;
      // Stripe の Customer(お金を払う側のアカウント) を作成
      final customerId = await _stripeRepo.createCustomer();
      await _userRepo.createUser(userId, customerId);
    }
    logger.i('AuthUser: ${_auth.currentUser?.uid}');
  }

  void onTabTapped(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
