import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stripe_platform_example/domain/product.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/repository/product_repository.dart';
import 'package:stripe_platform_example/repository/stripe_repository.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';

class ProductListModel extends ChangeNotifier {
  List<Product> products = [];
  User? user;
  bool isLoading = false;

  final _userRepo = UserRepository();
  final _productRepo = ProductRepository();
  final _stripeRepo = StripeRepository();

  Future<void> fetch() async {
    _startLoading();
    // ユーザー取得
    user = await _userRepo.fetch();
    // 商品一覧を取得
    products = await _productRepo.fetchProducts();
    // 出品者を取得
    for (final product in products) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(product.ownerId)
          .get();
      final data = doc.data();
      if (data != null) {
        product.owner = User.fromJson(data);
      }
    }
    _endLoading();
  }

  Future<void> createCharge(Product product) async {
    try {
      _startLoading();
      if (user?.sourceId == null) {
        throw 'クレジットカードを設定してください';
      }
      await _stripeRepo.createCharge(
          user?.customerId, product.price, product.owner?.accountId);
    } catch (e) {
      throw e.toString();
    } finally {
      _endLoading();
    }
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
