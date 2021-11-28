/// クレジットカード
/// （Firestore上にはデータを持たない。users.sourceIdから直接APIを叩いて取得する）
class CreditCard {
  String brand = '';
  String cardNumber = '';
  String exp = '';
  String cvc = '';
}
