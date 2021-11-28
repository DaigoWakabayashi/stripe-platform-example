import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

class StripeRepository {
  static final StripeRepository _instance = StripeRepository._internal();
  StripeRepository._internal();
  factory StripeRepository() {
    return _instance;
  }

  /// Customer（お金を受け取るアカウント）を作成し、customerIdを返す
  Future<String> createCustomer(String email) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-createCustomer');
    final functionResult = await callable.call({
      'email': email,
      'idempotencyKey': Uuid().v4(),
    });
    final data = functionResult.data;
    final String customerId = data['customerId'];
    return customerId;
  }
}
