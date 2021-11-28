import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';

class AccountModel extends ChangeNotifier {
  bool isLoading = false;
  User? user;

  final userRepo = UserRepository();

  Future<void> init() async {
    user = await userRepo.fetch();
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.FirebaseAuth.instance.signOut();
  }
}
