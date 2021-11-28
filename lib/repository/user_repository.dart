import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:stripe_platform_example/domain/user.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  UserRepository._internal();
  factory UserRepository() {
    return _instance;
  }

  User _user = User();
  final _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'id': userId,
      'displayName': 'Flutter大学生',
    });
  }

  Future<User> fetch() async {
    final id = auth.FirebaseAuth.instance.currentUser?.uid;
    final doc = await _firestore.collection('users').doc(id).get();
    final data = doc.data();
    if (data != null) {
      _user = User.fromJson(data);
    }
    return _user;
  }
}
