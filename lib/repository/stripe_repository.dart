class StripeRepository {
  static final StripeRepository _instance = StripeRepository._internal();
  StripeRepository._internal();
  factory StripeRepository() {
    return _instance;
  }

  Future<String> createCustomer() async {
    // todo : Stripe の customer 作成、customerId を返す
    return '';
  }
}
