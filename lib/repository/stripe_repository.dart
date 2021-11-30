import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stripe_platform_example/domain/stripe_individual.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:uuid/uuid.dart';

class StripeRepository {
  static final StripeRepository _instance = StripeRepository._internal();
  StripeRepository._internal();
  factory StripeRepository() {
    return _instance;
  }

  ///
  /// Customer（お金を払うアカウント ≒ 購入者）
  ///
  /// https://stripe.com/docs/api/customers/object

  /// customer を作成し、customerId を返す
  Future<String> createCustomer(String email) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-createCustomer');
    final functionResult = await callable.call({
      'email': email,
      'idempotencyKey': const Uuid().v4(),
    });
    final data = functionResult.data;
    final String customerId = data['customerId'];
    return customerId;
  }

  /// クレジットカードの取得
  Future retrieveCard(String customerId, String sourceId) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-retrieveCardInfo');
    final result = await callable.call({
      'customerId': customerId,
      'cardId': sourceId,
    });
    return result.data;
  }

  /// クレジットカードの登録
  Future<String> registerCard(String customerId, String cardToken) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-createCardInfo');
    final result = await callable.call({
      'customerId': customerId,
      'cardToken': cardToken,
    });
    final data = result.data;
    final sourceId = data['id'];
    return sourceId;
  }

  ///
  /// ConnectAccount（お金を受け取るアカウント ≒ 出品者）
  ///
  /// https://stripe.com/docs/api/accounts/object

  /// ConnectAccount を取得し、結果を map で返す
  Future<Map<String, dynamic>> retrieveConnectAccount(User? user) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-retrieveConnectAccount');
    final result = await callable.call({
      'accountId': user?.accountId,
    });
    final data = result.data;
    final json = Map<String, dynamic>.from(data['individual']);
    return json;
  }

  /// ConnectAccount を作成し、customerIdを返す
  Future<String> createConnectAccount(String email) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-createConnectAccount');
    final functionResult = await callable.call({
      'email': email,
      'idempotencyKey': const Uuid().v4(),
    });
    final data = functionResult.data;
    final String accountId = data['id'];
    return accountId;
  }

  /// ConnectAccount を更新する
  Future<void> updateConnectAccount(
    User? user,
    StripeIndividual? individual,
    TosAcceptance? tosAcceptance,
  ) async {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-updateConnectAccount');
    final _ = await callable.call({
      'accountId': user?.accountId,
      'individual': individual?.toJson(),
      'tos_acceptance': tosAcceptance?.toJson(),
    });
  }

  ///
  /// Charge（決済）
  ///

  /// 単発プランを購入する
  Future createCharge(
    String? customerId,
    int? amount,
    String? accountId,
  ) async {
    // 単発プランの決済
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'asia-northeast1',
    ).httpsCallable('stripe-createStripeCharge');

    await callable.call({
      'customerId': customerId,
      'amount': amount,
      'targetAccountId': accountId,
      'idempotencyKey': const Uuid().v4(),
    });
  }
}
