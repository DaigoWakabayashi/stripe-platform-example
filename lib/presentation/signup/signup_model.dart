import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpModel extends ChangeNotifier {
  final displayNameController = TextEditingController();
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> signUp() async {
    final credential = await FirebaseAuth.instance.signInAnonymously();
    final userId = credential.user?.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'id': userId,
      'displayName': displayNameController.text,
    });
  }
}
