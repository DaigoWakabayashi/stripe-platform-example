import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stripe_platform_example/domain/credit_card.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/repository/stripe_repository.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class EditCardModel extends ChangeNotifier {
  User? user;
  bool isCardRegister = false;
  bool isLoading = false;
  bool isFilledAll = false;
  late CreditCard creditCardNow;
  CreditCard newCreditCard = CreditCard();

  final userRepo = UserRepository();
  final stripeRepo = StripeRepository();

  final numberNode = FocusNode();
  final expNode = FocusNode();
  final cvcNode = FocusNode();

  /// 初期化
  Future fetch() async {
    _startLoading();
    user = await userRepo.fetch();
    await fetchCreditCard();
    _endLoading();
  }

  /// カード情報の取得
  Future fetchCreditCard() async {
    final sourceId = user?.sourceId;
    isCardRegister = sourceId != null;
    if (!isCardRegister) {
      // カードが登録されてなければ何もしない
      notifyListeners();
      return;
    }

    // カードが登録されていた場合はカード情報の取得
    final data =
        await stripeRepo.retrieveCard(user?.customerId ?? '', sourceId ?? '');
    final brand = data['brand'];
    final last4 = data['last4'];
    final expMonth = data['exp_month'];
    final expYear = data['exp_year'];

    final exp = expMonth.toString() + '/' + expYear.toString();

    creditCardNow = CreditCard();
    creditCardNow.brand = brand;
    creditCardNow.cardNumber = '**** **** **** $last4';
    creditCardNow.exp = exp;
  }

  /// ローカルのカードデータをクリアする
  void clearCardCache() {
    creditCardNow = newCreditCard;
    isCardRegister = false;
    notifyListeners();
  }

  /// カード番号
  void changeCreditNumber(text) {
    newCreditCard.cardNumber = text;
    checkIsFilled();
    notifyListeners();
  }

  /// 有効期限
  void changeExp(text) {
    newCreditCard.exp = text;
    checkIsFilled();
    notifyListeners();
  }

  /// CVC
  void changeCvc(text) {
    //AMEX: 4桁、それ以外が3桁
    newCreditCard.cvc = text;
    checkIsFilled();
    notifyListeners();
  }

  /// 入力されているかチェックする
  void checkIsFilled() {
    isFilledAll = newCreditCard.cardNumber.isNotEmpty &&
        newCreditCard.exp.isNotEmpty &&
        newCreditCard.cvc.isNotEmpty;
    notifyListeners();
  }

  /// フォーカスを解く
  void unFocusAll() {
    numberNode.unfocus();
    expNode.unfocus();
    cvcNode.unfocus();
    notifyListeners();
  }

  /// カード情報の保存
  Future saveCardInfo() async {
    if (newCreditCard.cardNumber.isEmpty) {
      throw ('カード番号を入力してください');
    }

    if (newCreditCard.exp.isEmpty) {
      throw ('カードの有効期限を入力してください');
    }

    if (newCreditCard.cvc.isEmpty) {
      throw ('カードのCVCを入力してください');
    }

    try {
      _startLoading();

      // stripeのcardTokenを取得
      final cardToken = await _fetchCardTokenFromStripeAPI();

      // userに保存する決済方法のsourceIdの取得
      final sourceId =
          await stripeRepo.registerCard(user?.customerId ?? '', cardToken);

      // sourceIDをuserに保存する
      await userRepo.updatePaymentMethod(sourceId: sourceId);

      // 最新のカード情報を取得
      userRepo.deleteLocalCache();
      await fetch();
    } catch (e) {
      throw ('カード情報の保存に失敗しました');
    } finally {
      _endLoading();
    }
  }

  // stripeAPIを直接叩いてcardTokenを取得
  // セキュリティ的にcard番号を自社のfirebaseに送信したくないため
  // cardTokenの取得だけは直接stripeのAPIを使って行う
  Future<String> _fetchCardTokenFromStripeAPI() async {
    // 有効期限（月/年）を分ける
    final expArray = newCreditCard.exp.split('/');
    final expMonth = int.parse(expArray[0]);
    final expYear = int.parse(expArray[1]);

    final stripeAPI = StripeApi(dotenv.env['STRIPE_PK'] as String);

    // 参考: https://stripe.com/docs/api/tokens/create_card
    final result = await stripeAPI.createToken(
      {
        'card': {
          'number': newCreditCard.cardNumber,
          'exp_month': expMonth,
          'exp_year': expYear,
          'cvc': newCreditCard.cvc,
        },
      },
    );
    final cardToken = result['id'];
    return cardToken;
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
