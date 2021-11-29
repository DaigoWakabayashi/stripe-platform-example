import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/utils/verification_status.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  UserRepository._internal();
  factory UserRepository() {
    return _instance;
  }

  User? _user;
  final _firestore = FirebaseFirestore.instance;

  /// user を新規作成する
  Future<void> createUser(
    auth.User? user,
    String customerId,
    String accountId,
  ) async {
    await _firestore.collection('users').doc(user?.uid).set({
      'id': user?.uid,
      'displayName': user?.displayName,
      'email': user?.email,
      'customerId': customerId,
      'accountId': accountId,
      'verificationStatus': Status.approved.toEnumString,
    });
  }

  /// 単一取得
  Future<User?> fetch() async {
    final id = auth.FirebaseAuth.instance.currentUser?.uid;
    final doc = await _firestore.collection('users').doc(id).get();
    final data = doc.data();
    if (data != null) {
      _user = User.fromJson(data);
    }
    return _user;
  }

  /// statusを返す
  Future<String> fetchStatus(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      return doc.data()?['status'];
    } catch (e) {
      return 'unknown';
    }
  }

  /// ローカルキャッシュを削除
  void deleteLocalCache() {
    _user = null;
  }

  /// カード情報（IDのみ）を保存する
  Future updatePaymentMethod({required String sourceId}) async {
    final user = await fetch();
    return _firestore.collection('users').doc(user?.id).update({
      'sourceId': sourceId,
    });
  }
}
