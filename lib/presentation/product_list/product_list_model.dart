import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stripe_platform_example/domain/product.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/repository/product_repository.dart';

class ProductListModel extends ChangeNotifier {
  List<Product> products = [];
  bool isLoading = false;

  final productRepo = ProductRepository();

  Future<void> fetch() async {
    _startLoading();
    // 商品一覧を取得
    products = await productRepo.fetchProducts();
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

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
